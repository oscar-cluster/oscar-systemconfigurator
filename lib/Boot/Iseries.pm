package Boot::Iseries;

#   $Header$

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
#   Donghwa John Kim <johkim@us.ibm.com>
#   Igor Grobman <ilgrobma@us.ibm.com>

=head1 NAME

Boot::Iseries - Iseries booting configuration module.

=head1 SYNOPSIS

  my $bootloader = new Boot::Iseries(%bootvars);

  if($bootloader->footprint_loader()) {
      $bootloader->install_config();
  }
  
  if($bootloader->footprint_config() && $bootloader->footprint_loader()) {
    $boot->install_loader();
  }

  my @fileschanged = $bootloader->files();

=cut

use strict;
use Carp;
use vars qw($VERSION);
use Boot;
use Util::Cmd qw(:all);
use Util::Log qw(:print);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Boot::boottypes, qw(Boot::Iseries);

sub new {
    my $class = shift;
    my %this = (
                root => "",
                filesmod => [],
		boot_bootdev => "", ### device to which Yaboot will be installed
		boot_timeout => 50,
                boot_rootdev => "",
                @_,
                boot_kernel => "/boot/vmlinux64",
                boot_prepboot => "",
               );

    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item files()

The files() method is merely an accessor method for the all files
touched by the instance during its run.

=cut

sub files {
    my $this = shift;
    return @{$this->{filesmod}};
}

=item footprint_loader()

This method returns "TRUE" if the iSeries architecture was detected.
There is not bootloader as such here. 

=cut

sub footprint_loader {
    my $this = shift;
    if (-d "$$this{root}/proc/iSeries") {
        return 1;
    }
    return 0;
}

=item footprint_config()

This method returns "TRUE" if default boot image has been specified 

=cut

sub footprint_config {
    return 1;
}

=item install_config()

This method is not useful for the iseries. It does absolutely nothing


=cut

sub install_config {
    return 1;
}


=item install_loader()

Write the default kernel into PReP partition

=cut

sub install_loader {
    my $this = shift;

    if($this->{boot_defaultboot}) {
        verbose("Setting boot kernel based on default boot");
        my $kernel = $this->defaultboot2kernel;
        if($kernel) {
            verbose("Setting boot kernel to $kernel");
            $this->{boot_kernel} = $kernel;
        } else {
            verbose("default boot doesn't make any sense, keeping global default $$this{boot_kernel}");
        }
    } else {
        verbose("boot_defaultboot was not set, so keeping global default $$this{boot_kernel}");
    }

    if(!$this->{boot_bootdev}) {
        verbose("boot_bootdev not set, so finding the first disk that makes sense");
        $this->{boot_bootdev} = find_bootdev();
    }
    
    if(!$this->{boot_bootdev}) {
        verbose("Couldn't determine bootdev dynamically");
        croak("No luck determining boot devices");
    }
    verbose("boot_bootdev set to $$this{boot_bootdev}");

    $this->{boot_prepboot} = find_prep_partition($this->{boot_bootdev});
    verbose("Set boot_prepboot to $$this{boot_prepboot}");

    if(!$this->{boot_prepboot}) {
        verbose("Couldn't determine prep partition");
        croak("No luck determining prep partition");
    }
    
    ### Now, let's copy the boot image to the boot partition.
    my $ddoutput = qx/dd if=$$this{boot_kernel} of=$$this{boot_prepboot} 2>&1/;
    my $exitval = $? >> 8;
    if ($exitval) {
        croak("$ddoutput\n");
    }
    1;
}

sub defaultboot2kernel {
    my $this = shift;

    my $default = $this->{boot_defaultboot};
    my $kernel = "";
    
    foreach my $key (sort keys %$this) {
        if ($key =~ /^(kernel\d+)_path/) {
            if ($this->{boot_defaultboot} eq $this->{$1 . "_label"}) {
                $kernel = $this->{root} . $this->{$1 . "_path"};
                last;
            }
        }
    }
    return $kernel;
}

sub find_prep_partition {
    my $dev = shift;
    my $part = "";
    verbose("Scanning $dev for prep boot partitions");
    if(open(FDISK, "fdisk -l $dev |")) { 
        while(<FDISK>) {
            s/\*//;
            if(/^(\/dev\/\S+)\s+\S+\s+\S+\s+\S+\s+(\w\w)\s+/) {
                debug("$1 has type $2");
                if($2 eq "41") {
                    $part = $1;
                    verbose("Found prep partition for device $2");
                    last;
                }
            }
        }
        close(FDISK);
    } else {
        carp ("Couldn't run 'fdisk -l $dev |'");
    }
    return $part;
}

sub find_bootdev {
    verbose("Attempting to find bootdevice based on partition scan");
    my @possible = ();
    opendir(DEV,"/dev");
    while(my $dev = readdir(DEV)) {
        if($dev =~ /^[hs]d\w$/) {
            verbose("Adding $dev to the list of possible boot devices");
            push @possible, "/dev/$dev";
        }
    }
    closedir(DEV);
    
    foreach my $dev (@possible) {
        verbose("Looking for prep partitions on $dev");
        my $part = find_prep_partition($dev);
        if($part) {
            return $dev;
        }
    }
}

=back

=head1 AUTHOR
  Igor Grobman <ilgrobma@us.ibm.com> based on YaBoot module written by 
  Donghwa John Kim <donghwajohnkim@yahoo.com>

=head1 SEE ALSO

L<SystemConifg::Boot>, L<perl>

=cut

1;




















