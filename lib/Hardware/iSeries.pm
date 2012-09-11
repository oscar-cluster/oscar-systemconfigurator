package Hardware::iSeries;

#   $Id: iSeries.pm 664 2007-01-15 21:40:36Z arighi $

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

use strict;
use Carp;
use Hardware::PCI::Table qw(:all);

use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Hardware::hardtypes, qw(Hardware::iSeries);

sub new {
    my $class = shift;
    my %this = (
                root => "",
                @_,
               );
    return bless \%this, $class;
}

sub footprint {
    my $this = shift;
    if(-r "$$this{root}/proc/iSeries") {
        return 1;
    }
    return undef;
}

# We need to add iSeries hardware lines in the iSeries environment

sub getlist {
    my $this = shift;

    my @hardware = ();

    my $veth = {
                type => "ethernet",
                module => "veth",
                vendor => "IBM",
                product => "Virtual Ethernet Driver",
               };

    push @hardware, $veth;
    
    return @hardware;    
}

=pod

=head1 NAME

Hardware::iSeries - detect pci devices from /proc/bus/pci/devices

=head1 SYNOPSIS

  my $detector = new Hardware::iSeries([root => $altroot]);

  my @hardware = $detector->getlist();

=head1 DESCRIPTION

DetectPCI is a simple program that reads /proc/bus/pci/devices and returns the list
of pci devices that it contains.  These can latter be translated to kernel modules by
a large hash table provided in Hardware::PCI::Table.

=head1 COPYRIGHT

Copyright 2001 International Business Machines

=head1 AUTHOR

Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConfig::Hardware>, L<perl>

=cut

1;





