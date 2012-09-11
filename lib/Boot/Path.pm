package Boot::Path;

#   $Header$

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

#   dann frazier <dannf@dannf.org>

use strict;
use Carp;
use File::Spec;

## ($device, $mount) = get_mount_info($file, $fstab)
## scans fstab to find the device and mountpoint on which a given file exists.
sub get_mountinfo {
    my ($this, $file, $fstab) = @_;
    
    my @path = File::Spec->splitdir($file);

    open(FSTAB, "<$fstab") or croak("Couldn't open $fstab for reading");
    ### cycle through fstab, each time chopping off another component from
    ### the end of our path name - we assume the longest parent path is the
    ### mount point.
    while($file && $file ne File::Spec->rootdir()) {
	seek FSTAB,0,0;

	pop @path;
	$file = File::Spec->catdir(@path);
	while(<FSTAB>) {
	    s/#.*//;   ## strip comments
	    if (m,^\s*(/dev/\S+\d+)\s+$file\s,) {
		close FSTAB;
		return ($1, $file);
	    }
	}
    }
    close FSTAB;
    return (undef, undef);
}

## $stripped = strip_parent($parent, $path)
##
## Return $path with the $parent component dropped.
## Could be done with a simple s//, but this should allow for
## more flexibility by allowing multiple strings to reference the
## same pathname.
sub strip_parent {
    my ($this, $parent, $path) = @_;

    $parent = File::Spec->canonpath($parent);
    $path = File::Spec->canonpath($path);

    if ($parent eq File::Spec->rootdir()) {
	return $path;
    }
    
    my @parentdirs = reverse File::Spec->splitdir($parent);
    my @pathdirs = reverse  File::Spec->splitdir($path);

    while (@parentdirs) {
	unless (@pathdirs) {
	    croak("$parent has more components than $path");
	}
	my $parentnext = pop @parentdirs;
	my $pathnext = pop @pathdirs;

	if ($parentnext ne $pathnext) {
	    croak("$path doesn't appear to be a path under $parent");
	}
    }
    return File::Spec->catdir(reverse (@pathdirs, "/"));
}
	
1;
