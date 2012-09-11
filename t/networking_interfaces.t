use Test;
use Data::Dumper;
use Carp;

BEGIN {
    
    # Set up 22 tests to run
    
    plan tests => 22;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --cfgfile t/cfg/test.cfg);
}

eval {
    require SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    require Network;
    return 1;
};

ok($@,'') or croak("No point in going any further");

# We loaded the file... now lets setup a fake directory to use

my $root = $config->root();

if(!$root) {
  croak("Running this not chroot is way too dangerous");
}

my $dir = $root . "/etc/network";

system("mkdir -p $dir");

if(!-d $dir) {
  croak("No directory $dir exists");
}

open(OUT,">$root/etc/network/interfaces");
print OUT "#test\n";
close(OUT);

croak() unless (-e "$root/etc/network/interfaces");

# Now we are ready to run tests.

Network::setup($config);

@lines = `cat $root/etc/network/interfaces`;
my $gw = $config->network_gateway();
my $matches = grep /$gw$/, @lines;

my $statcount;
$statcount = 0;
for my $line (@lines){
  next if ($line =~ /^\#/);
  $statcount++ if ($line =~ /static/);
}

# Does the number of matches equal to the number of static interfaces?
ok($matches,$statcount);

local($/) = undef;

ok(-e "$root/etc/network/interfaces");

open(IN,"<$root/etc/network/interfaces") or croak("Can't open /etc/network/interfaces");

my $file = <IN>;

ok($file,'/auto lo/');
ok($file,'/iface lo inet loopback/');
ok($file,'/auto dummy0/');
ok($file,'/iface dummy0 inet static/');
ok($file,'/\taddress 192.168.64.129/');
ok($file,'/\tnetmask 255.255.255.0/');
ok($file,'/\tbroadcast 192.168.64.255/');
ok($file,'/\tnetwork 192.168.64.0/');
ok($file,'/\tgateway 192.168.64.1/');
ok($file,'/auto dummy1/');
ok($file,'/iface dummy1 inet dhcp/');
ok($file,'/auto dummy2/');
ok($file,'/iface dummy2 inet bootp/');
ok($file,'/auto dummy3/');
ok($file,'/iface dummy3 inet dhcp/');

close(IN);

#did we do the hostname stuff right?
ok(-e "$root/etc/hostname");

open(IN,"<$root/etc/hostname") or croak("Can't open /etc/hostname");

$file = <IN>;
chomp $file;
ok($file,'/^test$/');

ok(system("rm -rf $root"),0);
