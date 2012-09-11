package Modules::Root;

#   $Id: Root.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001-2002 International Business Machines

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

Modules::Root - determine what modules are needed for root filesystem

=head1 SYNOPSIS

 my @modules = get_root_fs_modules('/etc/fstab');

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use base qw(Exporter);
use vars qw($VERSION @EXPORT);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

@EXPORT = qw(get_root_fs_modules get_root_raid_modules);

my %FS_MODULES = (
                  ext3 => ['ext3','jbd'],
                  reiserfs => ['reiserfs'],
                  xfs => ['xfs'],
		  jfs => ['jfs']
                 );

# find raid personality of an md device
# (added by Erich Focht, NEC, 03.02.2004)

sub find_raid_personality {
    my ($device) = @_;
    my $mdfile = "/proc/mdstat";
    if (-e $mdfile) {
	open INM, "<$mdfile" or croak "Could not open $mdfile";
	my $sdev=$device;
	$sdev =~ s:/dev/::;
	while (<INM>) {
	   if (/^$sdev\s+/) {
		my @line = split /\s+/;
		close INM;
		return $line[3];
	   }
	}
	close INM;
    }
    return "";
}

# find the modules needed for having raid on the root filesystem

sub get_root_raid_modules {
    my ($file) = @_;
    my @modules = ();
    open(INR,"<$file") or return @modules;
    while(<INR>) {
        my ($device, $mount, $fstype, $options, $one, $two) = split(/\s+/,$_);
        if($mount eq '/') {
	    if($device =~ /\/md/) {
		push @modules, find_raid_personality($device);
	    }
        }
    }
    close INR;
    return @modules;
}

# find the modules needed for a root filesystem

sub get_root_fs_modules {
    my ($file) = @_;
    my @modules = ();
    local *IN;
    open(IN,"<$file") or return ();
    while(<IN>) {
        my ($device, $mount, $fstype, $options, $one, $two) = split(/\s+/,$_);
        if($mount eq '/') {
            if($FS_MODULES{$fstype}) {
                push @modules, @{$FS_MODULES{$fstype}};
            }
        }
    }
    close IN;
    return @modules;
}

1;
