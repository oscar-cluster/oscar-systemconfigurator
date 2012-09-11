package Initrd::RH;

#   $Id: RH.pm 683 2007-09-18 20:26:17Z bli $

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
#
#   Erich Focht <efocht@hpce.nec.com>
#        - added allowmissing option

use strict;
use Carp;
use Data::Dumper;
use Initrd::Generic;
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 683 $ =~ /(\d+)/);

push @Initrd::rdtypes, qw(Initrd::RH);

sub footprint {
    my $class = shift;
    my $exe = "/sbin/mkinitrd";
    my $debconf = "/etc/mkinitrd/mkinitrd.conf";
    if(-f $exe && !-e $debconf) {
        return 1;
    }
    return 0;
}

sub setup {
    my ($class, $kernel) = @_;
    my $version = kernel_version($kernel);
    my $outfile = initrd_file($version);
    
    my $mkinitrd = "/sbin/mkinitrd_sis";
    my $allowmissing;
    if (!-x $mkinitrd) {
	if (!open OMK, ">$mkinitrd") {
	    carp("WARNING: Could not create copy of mkinitrd, creation of RH style initrd failed.");
	    return undef;
	}
	open IMK, "/sbin/mkinitrd";
	while (<IMK>) {
	    if (/allowmissing/) {
		$allowmissing = 1;
	    }
	    s/ cp -a / cp -aL /;
	    s/\tcp -a /\tcp -aL /;
	    print OMK;
	}
	close IMK;
	close OMK;
	system("chmod 755 $mkinitrd");
    }
    if ($allowmissing) {
        $allowmissing = "--allow-missing";
    } else {
        $allowmissing = '';
    }
    my $cmd = "$mkinitrd $allowmissing -f $outfile $version";
    my $rc = system($cmd);
    if($rc != 0) {
        carp("WARNING: RH style ramdisk generation failed.");
        return undef;
    } else {
        return $outfile;
    }

}

42;
