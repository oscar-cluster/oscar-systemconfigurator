package Initrd::Generic;

#   $Id: Generic.pm 664 2007-01-15 21:40:36Z arighi $

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
use Util::Log qw(:all);
use POSIX;
use base qw(Exporter);
use vars qw($VERSION $AUTOLOAD @EXPORT);

@EXPORT = qw(kernel_version initrd_file);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

# Super simple kernel version.  Just open the kernel an
# look for a line like 2.4.8-27stuff in it 

sub kernel_version {
    my $file = shift;
    my $version = '0.0.0';

    if(_is_gzip($file)) {
        open(IN,"gzip -dc $file |") or croak("Couldn't run gzip -dc $file");
    } else {
        open(IN,"<$file") or croak("Failed to open $file.");
    }
        
    while(<IN>) {
        # When Linux Kernel 4.0pre1 comes out, we'll have to change this
        if(/Linux version ([123]\.\d+\.[\w\-\.]+)/) {
            verbose("Found version '$1' at line # $.");
            $version = $1;
            last;
        }
    }
    if ($version eq "0.0.0") {
	# trying ia32 bzImage kind of thing
	my $buffer;
	if (seek(IN, 0x202, 0) && (read(IN, $buffer, 4) == 4) 
	    && (substr($buffer,0,4) eq "HdrS")
	    && seek(IN, 0x20e, 0) && (read(IN, $buffer, 2) == 2)) {
	    my $ofs = 0x200 + unpack("S", substr($buffer,0,2));
	    if (seek(IN, $ofs, 0) && (read(IN, $buffer, 80) == 80)) {
		$version = substr($buffer, 0, index($buffer, " "));
	    }
	}
    }
    close(IN); 

    return $version;

}

sub initrd_file {
    my ($version) = @_;
    my $rdfile = "/boot/sc-initrd-$version.gz";
    if( (uname)[4] eq "ia64") {
        # Itaniums need things in their special place
	if (-e "/etc/redhat-release") {
            $rdfile = "/boot/efi/EFI/redhat/sc-initrd-$version.gz";
	} elsif (-e "/etc/SuSE-release") {
	    $rdfile = "/boot/efi/SuSE/sc-initrd-$version.gz";
	} else {
	    $rdfile = "/boot/efi/sc-initrd-$version.gz";
	}
    }
    return $rdfile;
}

sub _is_gzip {
    my $file = shift;
    debug("opening $file to figure out if it is gzip archive");
    open(IN,"<$file") or (carp($!), return undef);
    my $chr1 = getc IN;
    my $chr2 = getc IN;
    debug(unpack("H*",$chr1));
    debug(unpack("H*",$chr2));
    close(IN) or (carp($!), return undef);
    if(unpack("H*",$chr2) eq "8b" and unpack("H*",$chr1) eq "1f") {
        debug("Is a gzip archive");
        return 1;
    } else {
        debug("Is not a gzip archive");
        return 0;
    }
}


sub DESTROY {
    # This makes sure that AUTOLOAD doesn't bitch on trying to call DESTROY
    return 1;
}

# Default Autoloader.  Means we don't have to define accessors for private data.
# This can probably be made more efficient through method caching, but
# I haven't gotten arround to it yet.

sub AUTOLOAD {
    my ($this) = @_;
    $AUTOLOAD =~ /.*::(\w+)/
      or croak("No such method: $AUTOLOAD");
    my $var = $1;

    exists $this->{"_$var"}
      or croak("No such method: $AUTOLOAD");
    
    return $this->{"_$var"};
}

42;
