package Network::Generic;

#   $Id: Generic.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001-2003 International Business Machines

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#   Sean Dague <sean@dague.net>

=head1 NAME

Network::Generic - A generic networking module

=head1 SYNOPSIS

  package Network::TypeA;

  use base qw(Network::Generic);

  my $networking = new Network::TypeA(%vars);

  if($networking->footprint()) {
      $networking->setup();
  }

  my @fileschanged = $networking->files();

=head1 DESCRIPTION

The Network::Generic module is the parent class of all Networking
implementations in the System Configurator project.  Network::Generic
defines a very robust constructor, as well as an AUTOLOAD method
which provides access to all the internal variables.

Any Network subclass should only need to implement footprint(), 
setup_global(), and setup_interface().  Each one of these functions
is explained below.

=cut

use strict;
use Carp;
use Network::Interface;
use Data::Dumper;
use Util::FileMod;
use vars qw($VERSION $AUTOLOAD @ISA);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub new {
    my $class = shift;
    my %this = (
                _root => "",
                _gateway => "",
                _gatewaydev => "",
                _dns1 => "",
                _dns2 => "",
                _dns3 => "",
                _search => "",
                _hostname => "",
                _domainname => "",
                _shorthostname => "",
                _filesmod => [],
                _interfaces => [],
               );
    
    my %config = @_;

    $this{_root} = $config{root};

    foreach my $item (qw(gateway dns1 dns2 dns3 search hostname domainname shorthostname)) {
        $this{"_" . $item} = $config{"network_" . $item};
    }
    
    my $intcfg;
    
    # Group and collect all the config information about the interfaces
    # into the intcfg hash

    foreach my $item (sort keys %config) {
        if ($item =~ /^(interface\d+)_(\w+)$/) {
            $intcfg->{$1}->{$2} = $config{$item};
        }
    }
    
    # Generate an interface object for each of these.  $this->{_interface}->[0] 
    # will now be the information in INTERFACE0_*

    foreach my $int (sort keys %$intcfg) {
        my $interface = Network::Interface->new(%{$intcfg->{$int}});
        push @{$this{_interfaces}}, $interface;
    }
    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item files()

If called with an arguement, it will add those files to the internal
storage array for modified files.  

files() always returns the files that have been modified so far.

=cut

sub files {
    my $this = shift;
    if (scalar(@_) > 0) {
        push @{$this->filesmod}, @_;
    }
    return @{$this->filesmod};
}

=item footprint()

This method will be specific to the particular subclass.  The parent method
croaks if it is not overwritten.

=cut

sub footprint {
    my $this = shift;
    croak("Danger Will Robinson... footprint must be implemented by the subclass!");
}

=item setup()

Setup contains 3 processing phases.  setup_dns, which is assumed to be
handled by the generic class; setup_global which 
will be called once per setup call; setup_interfaces, which will in turn call
setup_interface($interface) once for each interface.  Do not change the 
behavior of setup in a sub class unless you really know what you are doing.

=cut

sub setup {
    my $this = shift;
    
    $this->setup_dns();
    $this->setup_global();
    $this->setup_interfaces();
}

=item setup_global()

setup_global() is called once per setup().  Here is where files which specify
global options (like GATEWAY) should be modified.

=cut

sub setup_global {
    my $this = shift;
    croak("Setup_global needs to be defined by the subclass!");
}

=item setup_dns()

setup_dns() is called by setup() once.  It exists in Network::Generic because
most distributions use exactly the same method to setup dns files.  It
can be overloaded if required by a sub class.

=cut

sub setup_dns {
    my $this = shift;
    
    my $file = $this->chroot("/etc/resolv.conf");

    my $text;
    my $somethingtodo = 0;

    if ($this->search) {
        $text = "search " . $this->search . "\n";
        $somethingtodo++;
    } elsif ($this->domainname) {
        $text = "domain " . $this->domainname . "\n";
    }
    
    foreach my $ns (($this->dns1, $this->dns2, $this->dns3)) {
        if ($ns) {
            $text .= "nameserver $ns\n";
            $somethingtodo++;
        }
    }
    
    if ($somethingtodo) {
        open(OUT,">$file");
        print OUT $text;
        close(OUT);
        $this->files($file);
    }
    return 1;
}

=item setup_interfaces() 

this method just calls setup_interface once per interface, with the interface
object as the first item in the parameter list.

=cut

sub setup_interfaces {
    my $this = shift;
    
    foreach my $interface (@{$this->interfaces}) {
        $this->setup_interface($interface);
    }
    
}

=item setup_interface($interface) 

This will be called once per interface.  It will be passed a reference to the 
Network::Interface object that represents that interface.

=cut

sub setup_interface {
    my ($this, $interface) = @_;
    croak("setup_interface needs to be defined in the subclass!");
}

=item chroot 

A utility method.  $this->chroot($string) returns the string with an attached 
root if the root is needed.

=cut

sub chroot {
    my $this = shift;
    if (!$this->root) {
        return shift;
    } else {
        my $var = shift;
        return $this->root . $var;
    }
}

sub interface {
    my ($this, $num) = @_;
    return $this->{_interfaces}->[$num];
}

sub DESTROY {
    # This makes sure that AUTOLOAD doesn't bitch on trying to call DESTROY
    return 1;
}

# Default Autoloader.  Means we don't have to define accessors for private data.
# This can probably be made more efficient through method caching, but
# I haven't gotten arround to it yet.

sub AUTOLOAD {
    my ($this) = @_;
    $AUTOLOAD =~ /.*::(\w+)/
      or croak("No such method: $AUTOLOAD");
    my $var = $1;

    exists $this->{"_$var"}
      or croak("No such method: $AUTOLOAD");
    
    return $this->{"_$var"};
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConifg::Network>, L<Net::Netmask>, L<perl>

=cut

42;
