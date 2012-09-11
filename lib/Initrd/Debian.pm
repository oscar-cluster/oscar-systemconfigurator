package Initrd::Debian;

#   $Id: Debian.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2002 International Business Machines

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
use Initrd::Generic;
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Initrd::rdtypes, qw(Initrd::Debian);

sub footprint {
    my $class = shift;
    my $exe = "/usr/sbin/mkinitrd";
    my $debconf = "/etc/mkinitrd/mkinitrd.conf";
    if(-f $exe && -e $debconf) {
        return 1;
    }
    return 0;
}

sub setup {
    my ($class, $kernel) = @_;
    my $version = kernel_version($kernel);
    my $outfile = initrd_file($version);
    
    my $cmd = "mkinitrd -o $outfile /lib/modules/$version";
    my $rc = system($cmd);
    if($rc != 0) {
        carp("Debian style ramdisk generation failed.");
        return undef;
    } else {
        return $outfile;
    }

}

42;
