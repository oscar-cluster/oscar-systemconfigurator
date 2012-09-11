package Boot;

#   Copyright (c) 2001 International Business Machines

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

#   Donghwa John Kim <johkim@us.ibm.com>

use strict;
use Carp;
use Util::Log qw(:all);

#
#  Note: Order is important here.  It is the order in which the bootloaders
#  will be attempted.
#

use Boot::YaBoot;
use Boot::Iseries;
use Boot::EFI;
use Boot::Elilo;
use Boot::Lilo;
use Boot::Grub;
use Boot::Palo;
use Boot::Aboot;
use Boot::ZIPL;
use Boot::Kboot;

use vars qw(@boottypes $VERSION);

$VERSION = sprintf("%d", q$Revision: 697 $ =~ /(\d+)/);

sub install_config {
    my $config = shift;

    my @files = ();

    my %bootvars = purge_variables($config->varlist("^(root|boot_|kernel)"));
    my $complete = 0;

    # allow user to pick one boot type to be prefered, then just move it
    # to the head if its a known type
    if(my $prefer = $config->boot_prefered) {
        for (my $i = 0; $i < scalar(@boottypes); $i++) {
            if($prefer eq $boottypes[$i]) {
                splice @boottypes, $i, 1;
                unshift @boottypes, $prefer;
            }
        }
    }
    
    foreach my $boottype (@boottypes) {
        my $boot = $boottype->new(%bootvars);
        verbose("Attempting to setup ". ref($boot));
        if($boot->footprint_loader()) {
            eval {
                $complete = $boot->install_config();
            };
        }
        if($@) {
            verbose($@);
        }
        if ($complete && !$@) {
            push @files, $boot->files(); #accessor method for the files modified
            last;
        }
    }
 
    # We have a much more robust error condition now to catch all those rsync bugs
    unless ($complete) {
        print STDERR "Error: None of the following bootloaders were successfully setup on your system:\n";
        print STDERR (join ',', (map {s/Boot:://; $_;} @boottypes)) . "\n\n";
        exit(1);
    }
    return @files;
}

sub install_loader {
    my $config = shift;
    my %bootvars = purge_variables($config->varlist("^(root|boot_|kernel)"));
    my $complete = 0;
    
    # allow user to pick one boot type to be prefered, then just move it
    # to the head if its a known type
    if(my $prefer = $config->boot_prefered) {
        for (my $i = 0; $i < scalar(@boottypes); $i++) {
            if($prefer eq $boottypes[$i]) {
                splice @boottypes, $i, 1;
                unshift @boottypes, $prefer;
            }
        }
    }

    foreach my $boottype (@boottypes) {
        my $boot = $boottype->new(%bootvars);
	### install_loader depends on the existence of both 
	### the bootloader and the config file
        if($boot->footprint_config() && $boot->footprint_loader()) {
            eval {
                $complete = $boot->install_loader();
            };
        }
        last if ($complete && !$@);
        
        print STDERR "$@\n";
        
    }
    
    unless ($complete) {
        print STDERR "Error: None of the following bootloaders were successfully setup on your system:\n";
        print STDERR (join ',', (map {s/Boot:://; $_;} @boottypes)) . "\n\n";
        my $devname = $config->get('boot_bootdev');
        # only go down this path if you came from a System Installer image
        if($devname) {
            if(!-e $devname) {
                print STDERR "The boot device '$devname' doesn't appear to exist in your image.  Please check the integrity of your image.\n";
            } else {
                my $device = (stat($devname))[6];
                my $major = int($device / 256);
                my $minor = int($device % 256);
                if(!$major and !$minor) {
                    print STDERR "The boot device '$devname' appears to exist, but has major and minor numbers set to 0.  This usually means that you are using a version of 'rsync' which impropperly supports device files.\n";
                } else {
                    print STDERR "An unknown error occurred while setting '$devname' ($major,$minor) to be the boot device.\n";
                }
            }
        }
        exit(1);
    }
    return 1;
}

# Purge variables exists to trim the variables down to something reasonable
# before passing off to the sub modules.  This lets us iterate through the 
# kernel lists

# We remove all kernel_* stanzas that have a blank kernel_path, as well as 
# all blank boot_* variables.

sub purge_variables {
    my %vars = (@_);
    my %purgeme = (
                   boot_timeout => 1,
                   boot_vga => 1,
                  );
    my %unused;
    
    foreach my $key (sort keys %vars) {
        if($key =~ /^(.+)_path$/ and !$vars{$key}) {
            $unused{$1}++;
        }
    }

    foreach my $key (keys %vars) {
        if($key =~ /^(kernel\d+)/ and $unused{$1}) {
            delete $vars{$key};
        } elsif(!$vars{$key} and $purgeme{$key}) {
            delete $vars{$key};
        }
    }
    
    return %vars;
}

=head1 NAME
Boot - The front end to setting up bootloaders in
                     System Configurator. 

=head1 SYNOPSIS
    use Boot;

    my  @filesmodified = Boot::setup_boot(%bootvars);

=head1 DESCRIPTION
Boot is the front end interface to setting up bootloaders.

It determines the type of bootloader (GRUB, LILO, YABOOT) installed on the system
and invoked its setup() method, which completes the configuration of the bootloader. 

For Intel x86 machines, if both GRUB and LILO are installed, GRUB has the precedence
over LILO, meaning that if configuration of GRUB succeeds LILO will not be configured.   
    
=head1 MODULE INTERFACE

To write a bootloader module which will plug into Boot, your
module must implement the following methods:

=over 4

=item new(%bootvariables)

The constructor expects a hash which contains bootloader configuration options as 
returned by the AppConfig method varlist("^(root|boot_|kernel)"). 
This must return an instance of the bootloader type.

=item footprint()

This instance method takes no arguements.  
It returns 1 if the type of bootloader is determined to be installed on the system, 
undef otherwise.

=item setup()

This instance method take no arguements. 
It completes the configuration of the bootloader for which footprint() succeeded.

=item files()

This instance method takes no arguements.  
It returns, in list context, a list of all files modified by the module.

=back

=head1 AUTHOR

  Donghwa John Kim <johkim@us.ibm.com>

=head1 SEE ALSO

L<Config>, L<Boot::Lilo>,
L<Boot::Grub>, L<Boot::YaBoot>

=cut

1;


















