package Boot::Devfs;

#   $Id: Devfs.pm 661 2006-11-24 11:48:24Z efocht $

#   Copyright (c) 2002 International Business Machines

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

#   See the
#   GNU General Public License for more details.
 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#   Sean Dague <sean@dague.net>

use strict;
use Carp;
use Data::Dumper;
use Util::Cmd qw(:all);
use Util::Log qw(:all);
use base qw(Exporter);
use vars qw(%DEVFS @EXPORT);

@EXPORT = qw(devfs_lookup);

sub smells_like_devfs {
    my $entry = shift;
    if($entry =~ m{(disc|ide|scsi|md/\d)}) {
        return 1;
    }
    return 0;
}

sub devfs_lookup {
    my $dev = shift;
    my $prefix = "";

    return $dev unless smells_like_devfs($dev);
    
    if(!scalar(keys %DEVFS)) {
        _populate_devfs();
        verbose("Devfs table looks like: " . Dumper(\%DEVFS));
    }
    
    if($dev =~ s{^(/dev/)}{}) {
        $prefix = $1;
    }

    verbose("Looking up linux entry for devfs entry $dev");
    
    if($dev =~ s{/disc$}{}) {
        if($DEVFS{$dev}) {
            $dev = $DEVFS{$dev};
            verbose("Linux device $dev found for devfs style entry");
        }
    } elsif ($dev =~ s{/part(\d+)$}{}) {
        my $part = $1;
        if($DEVFS{$dev}) {
            $part = "p".$part if ($dev =~ /(cciss|ida)/);
            $dev = $DEVFS{$dev} . $part;
            verbose("Linux device $dev found for devfs style entry");
        }
    } elsif ($DEVFS{$dev}) {
        $dev = $DEVFS{$dev};
        verbose("Linux device $dev found for devfs style entry");
    } 
    verbose("devfs_lookup returning $prefix$dev");
    return $prefix . $dev;
}

sub _populate_devfs {
    open(IN,"</proc/partitions") or croak("Couldn't open /proc/partitions for reading.");
    my $disks;
    my $devfsscsi = 0;
   
    # build the translation table once
    while(<IN>) {
        $_ =~ s/^\s+//;

        # next if header or no text
        next if /^(major|$)/;

        my ($major, $minor, $blocks, $dev, $crap) = split(/\s+/,$_);
        
        if($dev =~ m{^md/(\d+)$}) {
            $DEVFS{$dev} = "md$1";
        } elsif($dev =~ m{^(ide/\S+)/disc$}) {
            $DEVFS{$1} = _devfs_transform($dev);
        } elsif($dev =~ m{^(scsi/\S+)/disc$}) {
            # if we have a devfs scsi disk and we want to get
            # back to old school format, we just count up each disk
            # and assign it to /dev/sdN in order
            $DEVFS{$1} = "sd" . chr(97 + $devfsscsi);
            $devfsscsi++;
        } elsif($dev =~ m{^(cciss|ida)/disc(\d+)/disc$}) {
            $DEVFS{"$1/disc$2"} = "$1/c0d$2"
        } elsif(-l "/dev/$dev") {
	    #EF# udev case with running devfsd
	    my $real = readlink("/dev/$dev");
	    if ($real =~ s{/disc$}{}) {
		$DEVFS{$real} = $dev;
	    }
	}
    }
    close(IN);
}

sub _devfs_transform {
    my $devfsentry = shift;
    my ($type, $host, $bus, $target, $lun, $part) = split(/\//,$devfsentry);
    # get rid of the keywords in the sections
    $bus =~ s/\D+//g;
    $target =~ s/\D+//g;
    $part =~ s/\D+//g;
    my $realentry = "hd";
    my $total = $bus * 2 + $target;

    # now we add the real entry... remembering that chr(97) == 'a'
    $realentry .= chr(97 + $total);
    # add the partition number.  $part should always be blank, but
    # it is here for completeness sake
    $realentry .= $part;

    return $realentry;
}

1;
