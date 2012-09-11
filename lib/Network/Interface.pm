package Network::Interface;

#   $Id: Interface.pm 664 2007-01-15 21:40:36Z arighi $

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

#   Sean Dague <sean@dague.net>

=head1 NAME

Network::Interface - a network interface abstraction

=head1 SYNOPSIS

  my $interface = new Network::Interface(
                                         DEVICE => 'eth0',
                                         IPADDR => '192.168.42.101',
                                         TYPE => 'static',
                                        );

  my $netmask = $interface->netmask;
  my $ip = $interface->ip;
  my $network = $interface->network;

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use vars qw($VERSION);
use Net::Netmask;

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub new {
    my $class = shift;
    my %this = (
                _DEVICE => "eth0",
                _IPADDR => "",
                _TYPE => "dhcp",
                _NETMASK => "",
                _network => undef,
               );

    my %vars = @_;
    
    # Yes, I know this is sort of ugly, but I want private variables with 
    # defaults.
    
    $this{_DEVICE} = $vars{device} || $this{_DEVICE};
    $this{_TYPE} = $vars{type} || $this{_TYPE};
    $this{_IPADDR} = $vars{ipaddr};
    $this{_NETMASK} = $vars{netmask};
    
    if ($this{_TYPE} eq "static" and $this{_IPADDR} and $this{_NETMASK}) {
        my $network = Net::Netmask->new($this{_IPADDR},$this{_NETMASK});
        $this{_network} = $network;
    }
    
    bless \%this, $class;
}

sub ip {
    return shift->{_IPADDR};
}

sub ipaddr {
    return shift->{_IPADDR};
}

sub netmask {
    return shift->{_NETMASK};
}

sub device {
    return shift->{_DEVICE};
}

sub type {
    return shift->{_TYPE};
}

sub network {
    my $this = shift;
    if ($this->{_network}) {
        return $this->{_network}->base();
    }
    return undef;
}

sub broadcast {
    my $this = shift;
    if ($this->{_network}) {
        return $this->{_network}->broadcast();
    }
    return undef;
}

=head1 METHODS

The following accessors exist in this module:

=over 4

=item ip

returns ip address

=item ipaddr

returns ip address

=item netmask

returns subnet mask

=item network

returns base network address

=item broadcast

returns broadcast address

=item device

returns device name

=item type

returns interface type (dhcp|static|bootp)

=back

=head1 AUTHOR

  Sean Dague
  sean@dague.net
  
=head1 SEE ALSO

Most of the hard work of this module is done by the L<Net::Netmask> module
written by David Muir Sharnoff.  The rest is just a mild abstraction layer on top
of that.

L<Network>, L<Net::Netmask>, L<perl>

=cut

1;
