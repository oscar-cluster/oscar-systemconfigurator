package Network::RawNetwork;

#   $Id: RawNetwork.pm 664 2007-01-15 21:40:36Z arighi $

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

#   Sean Dague <sldague@us.ibm.com>

=head1 NAME

Network::RawNetwork - Raw /etc/init.d/network Module

=head1 SYNOPSIS

  my $networking = new Network::RawNetwork(%vars);

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

push @Network::nettypes, qw(Network::RawNetwork);

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if Raw Networking style networking was discovered on the machine,
undef if it was not.  The current test checks for the existance of a line in 
/etc/init.d/network which consists entirely of 'ifconfig lo 127.0.0.1'.

=cut

sub footprint {
    my $this = shift;
    my $file = $this->chroot("/etc/init.d/network");

    local $/ = undef;
    open(IN,"<$file") or return undef;
    
    my $contents = <IN>;
    close(IN);

    if($contents =~ /[\n\r]ifconfig lo 127.0.0.1\s*[\n\r]/) {
        return 1;
    }
    return undef;
}

=item setup_global()

The setup() method sets up the file /$root/etc/init.d/network script to make raw
calls to ifconfig and route.  This networking will work for any distribution.  It also
creats an /etc/hostname file, as it seems that distributions that have this footprint
also use /etc/hostname to set the system hostname on boot.

=cut

sub setup_interfaces {
    # This has to be a noop to let us reuse setup_interface
    return 1;
}

sub setup_global {
    my $this = shift;
    
    my $file = $this->chroot("/etc/init.d/network");

    open(OUT,">$file") or croak("Couldn't open $file for writing");

    print OUT <<EOF;
#! /bin/sh
# This file generated by System Configurator
ifconfig lo 127.0.0.1
route add -net 127.0.0.0 netmask 255.0.0.0 lo

EOF

  foreach my $interface (@{$this->interfaces}) {
      $this->setup_interface($interface,\*OUT);
  }
    if($this->gateway) {
        print OUT "route add default gw " . $this->gateway . " metric 1\n";
    }
    close(OUT);
    $this->files($file);
    
    #Setup /etc/hostname
    
    $file = $this->chroot("/etc/hostname");
    open(OUT,">$file") or croak("Couldn't open $file for writing");
    print OUT $this->hostname,"\n";
    close(OUT);

    $this->files($file);
    return 1;
}

=item setup_interface()

setup_interface() method determines which network setup method will be used for the 
particular interface.  It only adds lines to the file in the event that it is a static
address.  Otherwise it is assumed that there is a dhcp client script elsewhere.

=cut

sub setup_interface {
    my ($this, $interface, $outfh) = @_;
    
    if($interface->type eq "static" and 
       $interface->ipaddr and
       $interface->netmask) {
        
        my $device = $interface->device;
        my $ipaddr = $interface->ipaddr;
        my $netmask = $interface->netmask;
        my $broadcast = $interface->broadcast;
        my $network = $interface->network;
        
        print $outfh <<EOF;

ifconfig $device $ipaddr netmask $netmask broadcast $broadcast
route add -net $network

EOF
    }
    return 1;
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConifg::Network>, L<Net::Netmask>, L<perl>

=cut

1;
