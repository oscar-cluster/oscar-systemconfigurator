package Initrd2;

#   $Id: Initrd2.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001-2005 International Business Machines

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
#   Vasilios Hoffman <greekboy@users.sourceforge.net>

use strict;
use Carp;
use POSIX;
use File::Copy;
use Util::Log qw(:all);
use Util::Cmd qw(:all);
use base qw(Exporter);
use vars qw(@EXPORT $VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

=head1 NAME

Initrd - builds initial ramdisks for kernels

=head1 SYNOPSIS

Initrd::setup($config);

=head1 DESCRIPTION

The Initrd module generates initial ramdisks for kernels, provided there is enough userland tools and kernel support to allow this.

=head1 AUTHOR

  Sean Dague <sean@dague.net>
  Vasilios Hoffman <greekboy@users.sourceforge.net>
  Erich Focht <efocht@hpce.nec.com>

=head1 SEE ALSO

L<Config>, 
L<perl>

=cut

sub setup {

    my $config = shift;

    my %kernels = $config->varlist("^kernel");
    my $root = $config->get("root");

    my (@ramdisks,@files) = ();
    my $ramdisk;

    foreach my $key (sort keys %kernels) {
        if($key =~ /(kernel\d+)_path/) {
            my $ramdisk = $1 . "_initrd";
            my $kernel = $kernels{$1 . "_path"};
            if (! exists $kernels{$ramdisk}) {
                debug("configuring ramdisk for $1");
                eval {
                    my $rdfile = create_initrd($root, $kernel);
                    if($rdfile) {
                        $config->set("$ramdisk",$rdfile);
                    } else {
                        croak("couldn't create ramdisk for $1");
                    }
                };
                if($@) {
                    carp ("Ramdisk creation for kernel $kernel has failed");
                }
            }
        }
    }
}

sub create_initrd {
    my ($root, $kernel) = @_;
    my $version = kernel_version("$root/$kernel");
    my $rdfile = "/boot/sc-initrd-$version.gz";
    if( (uname)[4] eq "ia64") {
        # Itaniums need things in their special place
        $rdfile = "/boot/efi/sc-initrd-$version.gz";
    }
    my $outfile = $root . $rdfile;
    if( -e "$root/etc/mkinitrd/mkinitrd.conf" ) {
        # This is now Debian 3.0
        if(exec_mkinitrd_debian($root, $outfile, $version)) {
            return $rdfile;
        }
    } else {
        if(exec_mkinitrd($root, $outfile, $version)) {
            return $rdfile;
        }
    }
    return undef;
}

sub exec_mkinitrd {
    my ($root, $outfile, $version) = @_;
    my $cmd = "mkinitrd $root$outfile $version";
    return !system($cmd);
}

sub exec_mkinitrd_debian {
    my ($root, $outfile, $version) = @_;
    my $cmd = "mkinitrd -o $root$outfile /lib/modules/$version";
    return !system($cmd);

}

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
        if(/Linux\ version\ ([123]\.\d+\.[\w\-\.]+)/) {
            verbose("Found version '$1' in line '$_'");
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

1;





