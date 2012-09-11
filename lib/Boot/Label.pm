package Boot::Label;

#   $Id: Label.pm 665 2007-02-15 19:49:06Z arighi $

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
use Boot::Devfs;
use Util::Cmd qw(:all);
use Util::Log qw(:all);

# gets the label for a device

sub dev2label {
    my $device = shift;
    if(-b $device) {
        $_ = saferun("blkid -s LABEL $device");
        if (defined($_)) {
            $_ =~ s/^.*LABEL="(.*)".*$/$1/;
        }
        return $_;
    }
    return "";
}

sub saferun {
    my $cmd = shift;
    my $data = `$cmd 2>/dev/null`;
    verbose("$cmd = $data");
    if($?) {
        debug("WARNING: Error while running $cmd. $!");
        return undef;
    } else {
        chomp $data;
        return $data;
    }
}

sub labels {
    local *IN;
    open(IN,"</proc/partitions") or (carp ("Couldn't open /proc/partitions"), return undef);
    my %labels = ();
    while(<IN>) {
        if(/^\s*$/ or /major/) {
            # then we have the header or a blank line, so skip it
            next;
        }
        my ($junk, $major, $minor, $blocks, $name, $rio, $rmerge, $rsect, $ruse, $wio, $wmerge, $wsect, $wuse, $runn,  $ng, $use, $aveq) = split (/\s+/,$_);
        my $device = "/dev/". devfs_lookup($name);
        # only get labels for partitions
        if($device =~ /\d+$/) {
            verbose("getting label for $device");
            my $label = dev2label($device);
            if($label) {
                verbose("label is $label");
                $labels{$label} = $device;
            }
        }
    }
    close(IN);
    return %labels;
}

sub fstab_struct {
    my $file = shift;
    my $struct;
    my %labels;
    local *IN;
    open(IN,"<$file") or (carp ("Couldn't open $file for reading"), return undef);
    while(<IN>) {
        # get rid of starting spaces
        s/^\s+//;
        
        # next if the line is a comment or space
        next if /^(\#|$)/;
        
        my ($device, $mount, $fstype, $options, $fsck, $order) = split(/\s+/,$_);
        my $label = "";
        if ($device =~ /none/) {
            next;
        }
        
        if($device =~ /LABEL=(.+)/) {
            if(!scalar(keys %labels)) {
                verbose("Loading labels for all devices...");
                %labels = labels();
                verbose("Label structure is as follows: " . Dumper(\%labels));
            }
            $label = $1;
            $device = $labels{$label};
            if(!$device) {
                carp("WARNING: Label $label not found anywhere on the system!");
                verbose("Labels are:" . Dumper(\%labels));
                next;
            }
        }
        
        $struct->{$device} = {
                              mount => $mount,
                              label => $label,
                              type => $fstype,
                             };
    }
    close(IN);
    return $struct;
}

1;
