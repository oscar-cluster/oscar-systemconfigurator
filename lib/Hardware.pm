package Hardware;

#   $Id: Hardware.pm 664 2007-01-15 21:40:36Z arighi $

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
use Data::Dumper;
use Hardware::PCI::Detect;
use Hardware::iSeries;
use Modules::RcConfig;
use Modules::SuSE8;
use Modules::ModutilsAliases;
use Modules::ModulesConf;
use Modules::ModprobeConf;
use Modules::ConfModules;

use vars qw(@hardtypes @conftypes $VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub setup {
    my $config = shift;

    my @hw = get_devices($config);
        
    my @aliases = create_aliases($config, @hw);
    return build_confs($config, @aliases);
}

sub get_devices {
    my $config = shift;

    my @hw;

    my %vars = $config->varlist("^(root)");

    foreach my $htype (@hardtypes) {
        my $hwtype = $htype->new(%vars);
        if($hwtype->footprint()) {
            push @hw, $hwtype->getlist();
        }
    }
    return @hw;
}

sub create_aliases {
    my $config = shift;
    my @hw = @_;
    
    my @aliases;

    my $eth = 0;
    my $tr = 0;
    my $scsi_hostadapter = "";

    @hw = sort_hwlist($config->hardware_order, @hw);

    for(my $i = 0; $i < scalar(@hw); $i++) {
        my $item = $hw[$i];
        if($item->{type} eq "ethernet") {
            push @aliases, ["eth$eth",$item->{module}];
            $eth++;
        }
        if($item->{type} eq "tokenring") {
            push @aliases, ["tr$tr",$item->{module}];
            $tr++;
        }
        if($item->{type} eq "scsi") {
            push @aliases, ["scsi_hostadapter$scsi_hostadapter", $item->{module}];
            $scsi_hostadapter++;
        }
    }
    return @aliases;
}

sub sort_hwlist {
    my $order = shift;
    my @list = @_;
    my @newlist = ();

    my @order = split(/\s+/,$order);

    # This enforces module order based on hardware_order
    # hence you can push items to the front of the list easily

    foreach my $item (@order) {
        while(defined(my $location = find_module($item, @list))) {
            push @newlist, $list[$location];
            splice(@list,$location,1);
        }
    }

    # This groups the rest of the list
    while(scalar(@list)) {
        my $item = shift(@list);
        push @newlist, $item;
        while(defined(my $location = find_module($item->{module}, @list))) {
            push @newlist, $list[$location];
            splice(@list,$location,1);
        }
    }
    return @newlist;
}

sub find_module {
    my $item = shift;
    my @list = @_;
    
    for (my $i = 0; $i < scalar(@list); $i++) {
        if($item eq $list[$i]->{module}) {
            return $i;
        }
    }
    return undef;
} 

sub build_confs {
    my $config = shift;
    my @aliases = @_;
    
    my @files = ();

    my %vars = $config->varlist("^(root|boot|kernel)");

    foreach my $conftype (@conftypes) {
        my $ctype = $conftype->new(%vars);

        if($ctype->footprint()) {
            if($ctype->setup(@aliases)) {
                push @files, $ctype->files();
            }
        }
    }
    
    return @files;
}

=pod

=head1 NAME

  SystemConfig::Hardware - Hardware Setup Module for System Configurator

=head1 SYNOPSIS

  use SystemConfig::Hardware;

  my @modifiedfiles = SystemConfig::Hardware::setup($config);

=head1 DESCRIPTION

The Hardware setup routine has 3 phases:

=over 4

=item get_devices($config)

In the get_devices stage pci device numbers are collected and returned.

This has only one module that it calls right now, which is SystemConfig::Hardware::DetectPCI.

=item create_aliases(@devices)

This creates a set of kernel aliases for the hardware that is found if it is
an ethernet or token ring card, or it is a scsi device.

=item build_confs(@aliases)

This modifies the appropriate conf files for the particular distribution.  It only modifies
the first type found so that footprints need not be quite as elaborate as before.

=back

=head1 COPYRIGHT

Copyright 2001 International Business Machines

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConfig::Kernel::ModutilsAliases>, L<SystemConfig::Kernel::ModulesConf>,
L<SystemConfig::Kernel::ConfModules>, L<SystemConfig::Hardware::DetectPCI>, L<perl>

=cut
1;





