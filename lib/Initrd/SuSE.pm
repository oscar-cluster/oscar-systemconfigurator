package Initrd::SuSE;

#   $Id: SuSE.pm 664 2007-01-15 21:40:36Z arighi $

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
use File::Basename;
use Modules::Deps;
use Initrd::Generic;
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Initrd::rdtypes, qw(Initrd::SuSE);

sub footprint {
    my $class = shift;
    my $exe = "/sbin/mk_initrd";
    if(-e $exe) {
        return 1;
    }
    return 0;
}

sub setup {
    my ($class, $kernel, $rootdev) = @_;

    my $version = kernel_version($kernel);
    my $outfile = initrd_file($version);
    my $short_kernel = basename($kernel);
    my $short_outfile = basename($outfile);
    my $modulesline = "";

    # not only do you have to give mk_initrd all of the
    # dependancies for a given module, BUT you also have
    # to put them on the cmdline in the right order!!!
    # hence there is a reverse at the end of the call.
    
    my @topmods = get_needed_modules();
    my @modules;
    foreach my $mod (@topmods) {
        my @deps = get_deps($version, $mod);
        push @modules, @deps, $mod;
    }
    
    # trim it down to 1 of each
    @modules = uniq(@modules);

    if(scalar(@modules)) {
        $modulesline = " -m \"" . join(' ', @modules) . "\"";
    }

    my $cmd = "mk_initrd $modulesline -d $rootdev -k $short_kernel -i $short_outfile";
    my $rc = system($cmd);

    # 0 is full success, 9 is successful creation of initrd, but some modules
    # which were requested don't exist.  We don't really care, as this will almost
    # always be requesting ext3 on SuSE 7 which compiled it into the kernel.
    if($rc == 0 or $rc == (9 * 256)) {
        return $outfile;
    } else {
        carp("SuSE style ramdisk generation failed.");
        return undef;
    }

}

sub get_needed_modules {
    my @possible = qw(/etc/sysconfig/kernel /etc/rc.config);
    my @modules;
    foreach my $file (@possible) {
        if(-e $file) {
            open(IN,"<$file") or next;
            while(<IN>) {
                if(/^\s*INITRD_MODULES=\"(.+?)\"/) {
                    push @modules, (split(/\s+/,$1));
                }
            }
            close(IN);
        }
    }
    return @modules;
}

42;
