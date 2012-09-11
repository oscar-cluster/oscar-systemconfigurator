package Hardware::PCI::Detect;

#   $Id: Detect.pm 664 2007-01-15 21:40:36Z arighi $

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

push @Hardware::hardtypes, qw(Hardware::PCI::Detect);

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
    if(-r "$$this{root}/proc/bus/pci/devices") {
        return 1;
    }
    return undef;
}

sub getlist {
    my $this = shift;

    my @hardware = ();

    # This loads overrides from the hardware.lst file
    Hardware::PCI::Table::_load_overrides('/etc/systemconfig/hardware.lst');
    
    open(IN,"<$$this{root}/proc/bus/pci/devices") or croak("Can't open $$this{root}/proc/bus/pci/devices");
    while(<IN>) {
        if(/^[0-9a-f]+\s+([0-9a-f]{8})\s+/) {
            my $devid = $1;
            my %entry = %{pci_entry($devid)};
            if(exists $entry{module}) {
                push @hardware, \%entry;
            }
        }
    }
    close(IN);
    
    return @hardware;    
}

=pod

=head1 NAME

Hardware::PCI::Detect - detect pci devices from /proc/bus/pci/devices

=head1 SYNOPSIS

  my $detector = new Hardware::PCI::Detect([root => $altroot]);

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





