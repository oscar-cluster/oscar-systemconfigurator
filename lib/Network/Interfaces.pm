package Network::Interfaces;

#   $Id: Interfaces.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001 International Business Machines

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

#   Donghwa John Kim <johkim@us.ibm.com>

=head1 NAME

Network::Interfaces - Interfaces Networking Module

=head1 SYNOPSIS

  my $networking = new Network::Interfaces(%vars);

  if($networking->footprint()) {
      $networking->setup();
  }

  my @fileschanged = $networking->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use vars qw($VERSION);
use base qw(Network::Generic);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Network::nettypes, qw(Network::Interfaces);

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if Interfaces style networking was discovered on the machine,
undef if it was not.  The current test checks for the existance of the file
B<$root/etc/network/interfaces>.

=cut

sub footprint {
    my $this = shift;
    my $file = $this->chroot("/etc/network/interfaces");
    if(-e $file) {
        return 1;
    }
    return undef;
}

=item setup()

The setup() method sets up the file /$root/etc/network/interfaces for Interfaces type networking. 
It iterates through all the network interfaces specified in the configuration file 
(and/or STDIN) and translates them into the format understood by B<ifup> and B<ifdown> binaries.
It also sets the hostname with the one provided, by modifying the /etc/hostname file.

=cut

sub setup_global {
    my $this = shift;
    
    my $file = $this->chroot("/etc/network/interfaces");
    open(OUT,">$file") or croak("Couldn't open $file for writing");
    
    #Before setting up any other interfaces, we will be setting up the loop back interface.
    print OUT <<HEADER;
# The loopback interface
# Interfaces that comes with Debian Potato does not like to see
# "auto" option before "iface" for the first device specified.   
iface lo inet loopback
auto lo

HEADER

    close(OUT);
    $this->files($file);

    #Now we put the hostname into /etc/hostname
    my $hostfile = $this->chroot("/etc/hostname");
    
    if($this->hostname) {
        open(OUT,">$hostfile") or croak("Couldn't open $file for writing");
        print OUT $this->hostname,"\n";
        close(OUT);
        $this->files($hostfile);
    }
    return 1;
}

=item setup_interface()
setup_interface() method determines which network setup method will be used for the 
particular interface. Currently Interfaces supports 3 types; static, dhcp, and bootp.
For more information read the man page for interfaces.  

=cut

sub setup_interface {
    my ($this, $interface) = @_;

    my $file = $this->chroot("/etc/network/interfaces");
    
    open(OUT,">>$file") or croak("Couldn't open file $file for appending!");

    if($interface->type eq "static" and
       $interface->ipaddr and
       $interface->netmask) {
        
        my $device = $interface->device;
        my $ipaddr = $interface->ipaddr;
        my $netmask = $interface->netmask;
        my $broadcast = $interface->broadcast;
        my $network = $interface->network;
        my $gateway;

	$gateway = "";
	if ($device eq $this->interface(0)->device) {
	  $gateway = "\tgateway " . $this->gateway;
	}

        
        print OUT <<INTERFACE;
# Device $device configured by System Configurator 

auto $device
iface $device inet static
\taddress $ipaddr
\tnetmask $netmask
\tbroadcast $broadcast
\tnetwork $network
$gateway

INTERFACE

    } elsif ($interface->type eq "bootp") {
        #do something for bootp
        my $device = $interface->device;

        print OUT <<INTERFACE;
auto $device 
iface $device inet bootp

INTERFACE
    } else {
        #and something else for dhcp
        my $device = $interface->device;
        
        print OUT <<INTERFACE;
auto $device 
iface $device inet dhcp

INTERFACE
    }
    close(OUT);

}

=back

=head1 AUTHORS

  Donghwa John Kim <donghwajohnkim@users.sourceforge.net>,
  Sean Dague <sldague@us.ibm.com>

=head1 SEE ALSO

L<Network>, L<Network::Generic>, L<perl>

=cut

1;




















