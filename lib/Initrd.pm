package Initrd;

#   $Id: Initrd.pm 664 2007-01-15 21:40:36Z arighi $

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
#   Vasilios Hoffman <greekboy@users.sourceforge.net>

use strict;
use Carp;
use POSIX;
use File::Copy;
use Util::Log qw(:all);
use Util::Cmd qw(:all);
use base qw(Exporter);
use vars qw(@EXPORT $VERSION @rdtypes);
use Initrd::SuSE;
use Initrd::RH;
use Initrd::Debian;

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

=head1 SEE ALSO

L<Config>, 
L<perl>

=cut

sub setup {

    my $config = shift;

    my (@ramdisks,@files) = ();

    foreach my $rdtype (@rdtypes) {
        verbose("Testing for ramdisk type '$rdtype'");
        if($rdtype->footprint()) {
            verbose("Setting up ramdisk type '$rdtype'");
            @files = setup_ramdisks($config, $rdtype);
            last if scalar(@files);
        }
    }
    return @files;
}

# Pretty simple, we pass in the config and the ramdisk type.
# If the kernel file exists, and the ramdisk doesn't, we try to build it.
# If the ramdisk now exists we add it to $config, which should propogate
# back up.

sub setup_ramdisks {
    my ($config, $rdtype) = @_;
    
    my @files = ();
    my @kernels = get_kernels($config);

    foreach my $kernel (@kernels) {
        my $kernelfile = $config->get($kernel . "_path");
        my $ramdisk = $config->get($kernel . "_initrd");
        my $rootdev = get_rootdev($config, $kernel);
        verbose("Setting up kernel: $kernelfile for root device: $rootdev");
        if(-e $kernelfile and !$ramdisk) {
            $ramdisk = $rdtype->setup($kernelfile, $rootdev);
            
            if($ramdisk and -e $ramdisk) {
                $config->set($kernel . "_initrd", $ramdisk);
                push @files, $ramdisk;
            }
        }
    }
    return @files;
}

sub get_rootdev {
    my ($config, $kernel) = @_;
    my $rootdev = $config->get($kernel . "_rootdev");
    $rootdev ||= $config->get('boot_rootdev');
    return $rootdev;
}

sub get_kernels {
    my $config = shift;
    my %kernels = $config->varlist("^kernel");
    my @keys = grep(/kernel\d+_path/, (sort keys %kernels));
    my @kernels = map {s/_path//; $_} @keys;
    return @kernels;
}

1;





