require 5.004;

package Net::Netmask;

use vars qw($VERSION);
$VERSION = 1.9;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(findNetblock findOuterNetblock findAllNetblock
	cidrs2contiglists range2cidrlist);
@EXPORT_OK = qw(int2quad quad2int %quadmask2bits imask);

my $remembered = {};
my %quadmask2bits;
my %imask2bits;
my %size2bits;

use vars qw($error $debug);
$debug = 1;

use strict;
use Carp;

sub new
{
	my ($package, $net, $mask) = @_;

	$mask = '' unless defined $mask;

	my $base;
	my $bits;
	my $ibase;
	undef $error;

	if ($net =~ m,^(\d+\.\d+\.\d+\.\d+)/(\d+)$,) {
		($base, $bits) = ($1, $2);
	} elsif ($net =~ m,^(\d+\.\d+\.\d+\.\d+):(\d+\.\d+\.\d+\.\d+)$,) {
		$base = $1;
		my $quadmask = $2;
		if (exists $quadmask2bits{$quadmask}) {
			$bits = $quadmask2bits{$quadmask};
		} else {
			$error = "illegal netmask: $quadmask";
		}
	} elsif (($net =~ m,^\d+\.\d+\.\d+\.\d+$,)
		&& ($mask =~ m,\d+\.\d+\.\d+\.\d+$,)) 
	{
		$base = $net;
		if (exists $quadmask2bits{$mask}) {
			$bits = $quadmask2bits{$mask};
		} else {
			$error = "illegal netmask: $mask";
		}
	} elsif (($net =~ m,^\d+\.\d+\.\d+\.\d+$,) &&
		($mask =~ m,0x[a-z0-9]+,i)) 
	{
		$base = $net;
		my $imask = hex($mask);
		if (exists $imask2bits{$imask}) {
			$bits = $imask2bits{$imask};
		} else {
			$error = "illegal netmask: $mask ($imask)";
		}
	} elsif ($net =~ /^\d+\.\d+\.\d+\.\d+$/ && ! $mask) {
		($base, $bits) = ($net, 32);
	} elsif ($net =~ /^\d+\.\d+\.\d+$/ && ! $mask) {
		($base, $bits) = ("$net.0", 24);
	} elsif ($net =~ /^\d+\.\d+$/ && ! $mask) {
		($base, $bits) = ("$net.0.0", 16);
	} elsif ($net =~ /^\d+$/ && ! $mask) {
		($base, $bits) = ("$net.0.0.0", 8);
	} elsif ($net =~ m,^(\d+\.\d+\.\d+)/(\d+)$,) {
		($base, $bits) = ("$1.0", $2);
	} elsif ($net =~ m,^(\d+\.\d+)/(\d+)$,) {
		($base, $bits) = ("$1.0.0", $2);
	} elsif ($net eq 'default') {
		($base, $bits) = ("0.0.0.0", 0);
	} elsif ($net =~ m,^(\d+\.\d+\.\d+\.\d+)\s*-\s*(\d+\.\d+\.\d+\.\d+)$,) {
		# whois format
		$ibase = quad2int($1);
		my $end = quad2int($2);
		$error = "illegal dotted quad: $net" 
			unless defined($ibase) && defined($end);
		my $diff = ($end || 0) - ($ibase || 0) + 1;
		$bits = $size2bits{$diff};
		$error = "could not find exact fit for $net"
			if ! defined($bits) && ! defined($error);
	} else {
		$error = "could not parse $net $mask";
	}

	carp $error if $error && $debug;

	$ibase = quad2int($base || 0) unless $ibase;
	$error = "could not parse $net $mask" 
		unless defined($ibase) || defined($error);
	$ibase &= imask($bits)
		if defined $ibase && defined $bits;

	return bless { 
		'IBASE' => $ibase,
		'BITS' => $bits, 
		( $error ? ( 'ERROR' => $error ) : () ),
	};
}

sub new2
{
	local($debug) = 0;
	my $net = new(@_);
	return undef if $error;
	return $net;
}

sub errstr { return $error; }
sub debug  { my $this = shift; return (@_ ? $debug = shift : $debug) }

sub base { my ($this) = @_; return int2quad($this->{'IBASE'}); }
sub bits { my ($this) = @_; return $this->{'BITS'}; }
sub size { my ($this) = @_; return 2**(32- $this->{'BITS'}); }
sub next { my ($this) = @_; int2quad($this->{'IBASE'} + $this->size()); }

sub broadcast 
{
	my($this) = @_;
	int2quad($this->{'IBASE'} + $this->size() - 1);
}

sub desc 
{ 
	my ($this) = @_; 
	return int2quad($this->{'IBASE'}).'/'.$this->{'BITS'};
}

sub imask 
{
	return (2**32 -(2** (32- $_[0])));
}

sub mask 
{
	my ($this) = @_;

	return int2quad ( imask ($this->{'BITS'}));
}

sub hostmask
{
	my ($this) = @_;

	return int2quad ( ~ imask ($this->{'BITS'}));
}

sub nth
{
	my ($this, $index, $bitstep) = @_;
	my $size = $this->size();
	my $ibase = $this->{'IBASE'};
	$bitstep = 32 unless $bitstep;
	my $increment = 2**(32-$bitstep);
	$index *= $increment;
	$index += $size if $index < 0;
	return undef if $index < 0;
	return undef if $index >= $size;
	return int2quad($ibase+$index);
}

sub enumerate
{
	my ($this, $bitstep) = @_;
	$bitstep = 32 unless $bitstep;
	my $size = $this->size();
	my $increment = 2**(32-$bitstep);
	my @ary;
	my $ibase = $this->{'IBASE'};
	for (my $i = 0; $i < $size; $i += $increment) {
		push(@ary, int2quad($ibase+$i));
	}
	return @ary;
}

sub inaddr
{
	my ($this) = @_;
	my $ibase = $this->{'IBASE'};
	my $blocks = int($this->size()/256);
	return (join('.',unpack('xC3', pack('V', $ibase))).".in-addr.arpa",
		$ibase%256, $ibase%256+$this->size()-1) if $blocks == 0;
	my @ary;
	for (my $i = 0; $i < $blocks; $i++) {
		push(@ary, join('.',unpack('xC3', pack('V', $ibase+$i*256)))
			.".in-addr.arpa", 0, 255);
	}
	return @ary;
}

sub quad2int
{
	my @bytes = split(/\./,$_[0]);

	return undef unless @bytes == 4 && ! grep {!(/\d+$/ && $_<256)} @bytes;

	return unpack("N",pack("C4",@bytes));
}

sub int2quad
{
	return join('.',unpack('C4', pack("N", $_[0])));
}

sub storeNetblock
{
	my ($this, $t) = @_;
	$t = $remembered unless $t;

	my $base = $this->{'IBASE'};

	$t->{$base} = [] unless exists $t->{$base};

	my $mb = maxblock($this);
	my $b = $this->{'BITS'};
	my $i = $b - $mb;

	$t->{$base}->[$i] = $this;
}

sub deleteNetblock
{
	my ($this, $t) = @_;
	$t = $remembered unless $t;

	my $base = $this->{'IBASE'};

	my $mb = maxblock($this);
	my $b = $this->{'BITS'};
	my $i = $b - $mb;

	return unless defined $t->{$base};

	undef $t->{$base}->[$i];

	for my $x (@{$t->{$base}}) {
		return if $x;
	}
	delete $t->{$base};
}

sub findNetblock
{
	my ($ipquad, $t) = @_;
	$t = $remembered unless $t;

	my $ip = quad2int($ipquad);

	for (my $b = 32; $b >= 0; $b--) {
		my $im = imask($b);
		my $nb = $ip & $im;
		next unless exists $t->{$nb};
		my $mb = imaxblock($nb, 32);
		my $i = $b - $mb;
		confess "$mb, $b, $ipquad, $nb" if $i < 0;
		confess "$mb, $b, $ipquad, $nb" if $i > 32;
		while ($i >= 0) {
			return $t->{$nb}->[$i]
				if defined $t->{$nb}->[$i];
			$i--;
		}
	}
}

sub findOuterNetblock
{
	my ($ipquad, $t) = @_;
	$t = $remembered unless $t;

	my $ip = quad2int($ipquad);

	for (my $b = 0; $b <= 32; $b++) {
		my $im = imask($b);
		my $nb = $ip & $im;
		next unless exists $t->{$nb};
		my $mb = imaxblock($nb, 32);
		my $i = $b - $mb;
		confess "$mb, $b, $ipquad, $nb" if $i < 0;
		confess "$mb, $b, $ipquad, $nb" if $i > 32;
		while ($i >= 0) {
			return $t->{$nb}->[$i]
				if defined $t->{$nb}->[$i];
			$i--;
		}
	}
}

sub findAllNetblock
{
	my ($ipquad, $t) = @_;
	$t = $remembered unless $t;
	my @ary ;
	my $ip = quad2int($ipquad);

	for (my $b = 32; $b >= 0; $b--) {
		my $im = imask($b);
		my $nb = $ip & $im;
		next unless exists $t->{$nb};
		my $mb = imaxblock($nb, 32);
		my $i = $b - $mb;
		confess "$mb, $b, $ipquad, $nb" if $i < 0;
		confess "$mb, $b, $ipquad, $nb" if $i > 32;
		while ($i >= 0) {
			push(@ary,  $t->{$nb}->[$i])
				if defined $t->{$nb}->[$i];
			$i--;
		}
	}
	return @ary;
}

sub match
{
	my ($this, $ip) = @_;
	my $i = quad2int($ip);
	my $imask = imask($this->{BITS});
	if (($i & $imask) == $this->{IBASE}) {
		return (($i & ~ $imask) || "0 ");
	} else {
		return 0;
	}
}

sub maxblock 
{ 
	my ($this) = @_;
	return imaxblock($this->{'IBASE'}, $this->{'BITS'});
}

sub imaxblock
{
	my ($ibase, $tbit) = @_;
	confess unless defined $ibase;
	while ($tbit > 0) {
		my $im = imask($tbit-1);
		last if (($ibase & $im) != $ibase);
		$tbit--;
	}
	return $tbit;
}

sub range2cidrlist
{
	my ($startip, $endip) = @_;

	my $start = quad2int($startip);
	my $end = quad2int($endip);

	($start, $end) = ($end, $start)
		if $start > $end;

	my @result;
	while ($end > $start) {
		my $maxsize = imaxblock($start, 32);
		my $maxdiff = 32 - int(log($end - $start + 1)/log(2));
		$maxsize = $maxdiff if $maxsize < $maxdiff;
		push (@result, bless {
			'IBASE' => $start,
			'BITS' => $maxsize
		});
		$start += 2**(32-$maxsize);
	}
	return @result;
}

sub cidrs2contiglists
{
	my (@cidrs) = sort blocksort @_;
	my @result;
	while (@cidrs) {
		my (@r) = shift(@cidrs);
		push(@r, shift(@cidrs))
			while $cidrs[0] && $r[$#r]->{'IBASE'} + $r[$#r]->size 
				== $cidrs[0]->{'IBASE'};
		push(@result, [@r]);
	}
	return @result;
}

sub blocksort
{
	$a->{'IBASE'} <=> $b->{'IBASE'}
		|| $a->{'BITS'} <=> $b->{'BITS'};
}

BEGIN {
	for (my $i = 0; $i <= 32; $i++) {
		$imask2bits{imask($i)} = $i;
		$quadmask2bits{int2quad(imask($i))} = $i;
		$size2bits{ 2**(32-$i) } = $i;
	}
}
1;
__END__
=head1 NAME

Net::Netmask - parse, manipulate and lookup IP network blocks

=head1 SYNOPSIS

	use Net::Netmask;

	$block = new Net::Netmask (network block)
	$block = new Net::Netmask (network block, netmask)
	$block = new2 Net::Netmask (network block)
	$block = new2 Net::Netmask (network block, netmask)

	print $block->desc() 		# a.b.c.d/bits
	print $block->base() 
	print $block->mask() 
	print $block->hostmask() 
	print $block->bits() 
	print $block->size() 
	print $block->maxblock()
	print $block->broadcast()
	print $block->next()
	print $block->match($ip);
	print $block->nth(1, [$bitstep]);

	for $ip ($block->enumerate([$bitstep])) { }

	for $zone ($block->inaddr()) { }

	my $table = {};
	$block->storeNetblock([$table])
	$block->deleteNetblock([$table])

	$block = findNetblock(ip, [$table])
	$block = findOuterNetblock(ip, [$table])
	@blocks = findAllNetblock(ip, [$table])

	@blocks = range2cidrlist($beginip, $endip);

	@listofblocks = cidrs2contiglists(@blocks);

=head1 DESCRIPTION

Net::Netmask parses and understands IPv4 CIDR blocks.  It's built
with an object-oriented interface.  Nearly all functions are 
methods that operate on a Net::Netmask object.

There are methods that provide the nearly all bits of information
about a network block that you might want.

=head1 CONSTRUCTING

Net::Netmask objects are created with an IP address and optionally
a mask.  There are many forms that are recognized:

=over 32

=item '140.174.82.0/24'

The preferred form.

=item '140.174.82.0:255.255.255.0'

=item '140.174.82.0', '255.255.255.0'

=item '140.174.82.0', '0xffffff00'

=item '140.174.82.0 - 140.174.82.255'

=item '140.174.82.4'

A /32 block.

=item '140.174.82'

Always a /24 block.

=item '140.174'

Always a /16 block.

=item '140'

Always a /8 block.

=item '140.174.82/24'

=item '140.174/16'

=item 'default'

0.0.0.0/0 (the default route)

=back

There are two constructor methods: C<new> and C<new2>.  The difference
is that C<new2> will return undef for invalid netmasks and C<new> will
return a netmask object even if the constructor could not figure out
what the network block should be.

With C<new>, the error string can be found as $block->{'ERROR'}.  With
C<new2> the error can be found as Net::Netmask::errstr or 
$Net::Netmask::error.

=head1 METHODS

=over 25

=item B<base>()

Returns base address of the network block as a string.  Eg: 140.174.82.0.  
B<Base> does not give an indication of the size of the network block.

=item B<mask>()

Returns the netmask as a string. Eg: 255.255.255.0. 

=item B<hostmask>()

Returns the host mask which is the oposite of the netmask. 
Eg: 0.0.0.255.

=item B<bits>()

Returns the netmask as a number of bits in the network
portion of the address for this block.  Eg: 24.

=item B<size>()

Returns the number of IP addresses in a block.  Eg: 256.

=item B<broadcast>()

The blocks broadcast address. (The last IP address inside the
block.) Eg: 192.168.1.0/24 => 192.168.1.255

=item B<next>()

The first IP address following the block. (The IP address following
the broadcase address.) Eg: 192.168.1.0/24 => 192.168.2.0

=item B<match>($ip)

Returns a true if the IP number $ip matches the given network. That
is, a true value is returned if $ip is between base() amd broadcast().
For example, if we have the network 192.168.1.0/24, then

  192.168.0.255 => 0
  192.168.1.0   => "0 "
  192.168.1.1   => 1
  ...
  192.168.1.255 => 255

$ip should be a dotted-quad (eg: "192.168.66.3")

It just happens that the return value is the position within the block.
Since zero is a legal position, the true string "0 " is returned in
it's place.  "0 " is numerically zero though.  When wanting to know
the position inside the block, a good idiom is:

  $pos = $block->match($ip) || die;
  $pos += 0;

=item B<maxblock>()

Much of the time, it is not possible to determine the size
of a network block just from it's base address.  For example,
with the network block '140.174.82.0/27', if you only had the
'140.174.82.0' portion you wouldn't be able to tell for certain
the size of the block.  '140.174.82.0' could be anything from a
'/23' to a '/32'.  The B<maxblock>() method gives the size of 
the larges block that the current block's address would allow it
to be.  The size is given in bits.  Eg: 23.

=item B<enumerate>([$bitstep)

Returns a list of all the IP addresses in the block.  Be very 
careful not to use this function of large blocks.  The IP
addresses are returned as strings.  Eg: '140.174.82.0', '140.174.82.1',
... '140.174.82.255'.

If the optional argument is given, step through the block in
increments of a given network size.  To step by 4, use a bitstep
of 30 (as in a /30 network).

=item B<nth>($index, [$bitstep])

Returns the nth element of the array that B<enumerate> would return
if it were called.  So, to get the first usable address in a block,
use B<nth>(1).  To get the broadcast address, use B<nth>(-1).  To
get the last usable adress, use B<nth>(-2).

=item B<inaddr>()

Returns an inline list of tuples.  There is a tuple for each
DNS zone name in the block.  If the block is smaller than a /24, 
then the zone of the enclosing /24 is returned. 

Each tuple contains: the DNS zone name, the last component of
the first IP address in the block in that zone, the last component
of the last IP address in the block in that zone.  

Examples: the list returned for the block '140.174.82.0/23' would
be: '82.174.140.in-addr.arpa', 0, 255, '83.174.140.in-addr.arpa', 0, 255.
The list returned for the block '140.174.82.64/27' would be: 
'82.174.140.in-addr.arpa', 64, 95.

=item B<storeNetblock>([$t])

Adds the current block to an table of network blocks.  The 
table can be used to query which network block a given IP address
is in.  

The optional argument allows there to be more than one table.
By default, an internal table is used.   If more than one table
is needed, then supply a reference to a HASH to store the 
data in.

=item B<deleteNetblock>([$t])

Deletes the current block from a table of network blocks.

The optional argument allows there to be more than one table.
By default, an internal table is used.   If more than one table
is needed, then supply a reference to a HASH to store the 
data in.

=back

=head1 FUNCTIONS

=over 25

=item B<findNetblock>(ip, [$t])

Search the table of network blocks (created with B<storeNetBlock>) to
find if any of them contain the given IP address.  The IP address
is expected to be a string.  If more than one block in the table
contains the IP address, the smallest network block will be the 
one returned.

The return value is either a Net::Netmask object or undef.

=item B<findOuterNetblock>(ip, [$t])

Search the table of network blocks (created with B<storeNetBlock>) to
find if any of them contain the given IP address.  The IP address
is expected to be a string.   If more than one block in the table
contains the IP address, the largest network block will be the 
one returned.

The return value is either a Net::Netmask object or undef.

=item B<findAllNetblock>(ip, [$t])

Search the table of network blocks (created with B<storeNetBlock>) to
find if any of them contain the given IP address.  The IP address
is expected to be a string.   All network blocks in the table that
contain the IP address will be returned.

The return value is a list of Net::Netmask objects.

=item B<range2cidrlist>($startip, $endip)

Given a range of IP addresses, return a list of blocks that
span that range.

For example, range2cidrlist('216.240.32.128', '216.240.36.127'),
will return a list of Net::Netmask objects that corrospond to:

	216.240.32.128/25
	216.240.33.0/24
	216.240.34.0/23
	216.240.36.0/25

=item B<cidrs2contiglists>(@listOfBlocks)

C<cidrs2contiglists> will rearange a list of Net::Netmask objects
such that contigueous sets are in sublists and each sublist is
discontigeous with the next.

For example, given a list of Net::Netmask objects corrosponding to
the following blocks:

	216.240.32.128/25
	216.240.33.0/24
	216.240.36.0/25

C<cidrs2contiglists> will return a list with two sublists:

	216.240.32.128/25 216.240.33.0/24

	216.240.36.0/25

The behavior for overlapping blocks is not currently defined.

=back

=head1 COPYRIGHT

Copyright (C) 1998, 2001 David Muir Sharnoff.   All rights reserved.
License hereby granted for anyone to use this module at their own risk.   
Please feed useful changes back to muir@idiom.com.

