package Network;

#   $Id: Network.pm 664 2007-01-15 21:40:36Z arighi $

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

use strict;
use Carp;
use Network::LinuxConf;
use Network::Interfaces;
use Network::RCConfig;
use Network::RawNetwork;
use Network::SuSE8;
use Data::Dumper;
use Util::Log qw(:all);

use vars qw(@nettypes $VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub setup {
    my $config = shift;
    
    my %netvars = $config->varlist("^(network|interface|root)");

    if(!$netvars{network_gatewaydev}) {
        $netvars{network_gatewaydev} = $netvars{interface0_device};
    }

    # now we do a purge of all the variables that we aren't using
    foreach my $key (keys %netvars) {
        if($key =~ /interface/) {
            delete $netvars{$key} if !$netvars{$key};
        }
    }

    my @files;
    
    foreach my $nettype (@nettypes) {
        my $networking = $nettype->new(%netvars);
        if($networking->footprint()) {
            verbose("Setting up network type $nettype");
            $networking->setup();
            push @files, $networking->files(); 
        }
    }
    return @files;
}

=head1 NAME

SystemConfig::Network - Interface to Networking for SystemConfigurator

=head1 SYNOPSIS

use Network;

my @filesmodified = Network::setup(%vars);

=head1 DESCRIPTION

Network is the core networking module for System Configurator.

It makes a series of use calls to all the individual modules that implement 
specific types of networking, then loops through each one in turn, 
calling the interface defined below.

=head1 MODULE INTERFACE

To write a Network Module which will plug into Network, your
module should be a subclass of Network::Generic.  It must then overload
certain methods.  Please see L<Network::Generic> for more information.

=head1 AUTHOR

Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<Network::Generic>

=cut
1;

__END__





