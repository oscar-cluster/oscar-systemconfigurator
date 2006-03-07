package Boot::EFI;

#   $Header: /cvsroot/systemconfig/systemconfig/lib/Boot/EFI.pm,v 1.10 2004/03/15 01:56:47 dannf Exp $

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

#   dann frazier <dannf@ldl.fc.hp.com>
#   based on code by:  Donghwa John Kim <johkim@us.ibm.com>

#   EFI caveats:
#   the kernel path names in elilo.conf (and therefore in systemconfig.conf)
#   must be relative to the efipartition, and apparently in efi syntax.

#   i.e.:x

#   image=/boot/efi/vmlinuz         BAD
#   image=vmlinuz                   GOOD
#   image=/vmlinuz                  BAD
#   image=\vmlinuz                  GOOD
    

=head1 NAME

Boot::EFI - EFI bootloader configuration module.

=head1 SYNOPSIS

  my $bootloader = new Boot::EFI(%bootvars);

  if($bootloader->footprint()) {
      $bootloader->setup();
  }

  my @fileschanged = $bootloader->files();

=cut

use strict;
use Carp;
use vars qw($VERSION);
use Boot;
use Util::Log qw(:all);
use Util::Cmd qw(:all);

$VERSION = sprintf("%d.%02d", q$Revision: 1.10 $ =~ /(\d+)\.(\d+)/);

push @Boot::boottypes, qw(Boot::EFI);

sub new {
    my $class = shift;
    my %this = (
                root => "",
                filesmod => [],
		bootloader_exe => "",
                bootmenu_exe => "",
		boot_bootdev => "",
                boot_timeout => 50,
                @_,
                config_file => "",
               );

    my @elilo_locations = qw(
			      /boot/efi
			      /boot/efi/efi/redhat
			      /boot/efi/EFI/redhat
			      /boot/efi/efi/sgi
			      /boot/efi/SuSE
			      /boot/efi/efi/SuSE	
			      );

    foreach my $possible (@elilo_locations) {
	my $file = $this{root} . $possible . "/elilo.efi";
	if ( -e $file ) {
	    $this{bootloader_exe} = $file;
	    $this{config_file} = $this{root} . $possible . "/elilo.conf";
	}
    }
    debug("bootloader_exe has been set to " . $this{bootloader_exe});

    $this{bootmenu_exe} = which('efibootmgr');

    debug("bootmenu_exe has been set to " . $this{bootmenu_exe});

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

=item footprint()

This method returns 1 if EFI bootloader is installed. 

=cut

sub footprint_config {
    my $this = shift;
    return -e $$this{config_file};
}

sub footprint_loader {
    my $this = shift;
    
    return ((-f $$this{bootloader_exe})
	    and $$this{bootmenu_exe} and $$this{bootloader_exe});
}


=item setup_config()

#This is for parsing the /etc/fstab and getting the boot device and
#partition number
This method read the System Configurator's config file and translates it
into the bootloader's "native" config file. 

=cut

sub install_config {
    my $this = shift;

    if(!$$this{boot_defaultboot}) 
    {
	croak("Error: DEFAULTBOOT must be specified.\n");;
    }

    open(OUT,">$$this{config_file}") or croak("Couldn\'t open $$this{config_file} for writing");
    print OUT <<ELILOCONF;
##################################################
# This file is generated by System Configurator. #
##################################################

# The number of deciseconds (0.1 seconds) to wait before booting
prompt
timeout=$$this{boot_timeout}
$this->{boot_extras}

# the default label to boot
default=$$this{boot_defaultboot}

ELILOCONF
  
  # Now we append the items that may have not been there previously
  
    if ($this->{boot_rootdev}) {
        print OUT "# Device to be mounted as the root ('/') \n";
        print OUT "root=" . $this->{boot_rootdev} . "\n";
    }
    if ($this->{boot_append}) {
        print OUT "# Kernel command line options. \n"; 
        print OUT "append=" . "\"" . $this->{boot_append} . "\"" . "\n";
    }   
    
    foreach my $key (sort keys %$this) {
        if ($key =~ /^(kernel\d+)_path/) {
            $this->setup_kernel($1,\*OUT);
        }
    }
    
    close(OUT);

    push @{$this->{filesmod}}, "$$this{config_file}";
    1;
}

=item setup_kernel()

An "internal" method.
This method sets up a kernel image as specified in the config file.

=cut

sub setup_kernel {
    my ($this, $kernel, $outfh) = @_;
    
    if ($$this{$kernel . "_label"} eq $$this{boot_defaultboot}) {
	unless ($$this{boot_rootdev} || $$this{$kernel . "_rootdev"}) {
	    croak("ROOTDEV must be specified either globally or locally.");
	    close($outfh);
	}
    }
    
    my $image = efi_friendly($$this{$kernel . "_path"});
    my $skernel = strip_path($$this{$kernel . "_path"});

    print $outfh <<LILOCONF;
#----- Options for \U$kernel\E -----#
image=$skernel
\tlabel=$$this{$kernel . "_label"}
\tread-only
LILOCONF

    ### Check for command line kernel options. 
    if ($this->{$kernel . "_append"}) {
	print $outfh "\tappend=" . "\"" . $this->{$kernel . "_append"} . "\"" . "\n";
    }

    ### Override global rootdev option?
    if ($this->{$kernel. "_rootdev"}) {
        print $outfh "\troot=" . $this->{$kernel . "_rootdev"} . "\n";
    }    

    ### Initrd image
    if ($this->{$kernel. "_initrd"}) {
        print $outfh "\tinitrd=" . strip_path($this->{$kernel . "_initrd"}) . "\n";
    }        
}

#   EFI caveats:
#   the kernel path names in elilo.conf (and therefore in systemconfig.conf)
#   must be relative to the efipartition, and apparently in efi syntax.

#   i.e.:

#   image=/boot/efi/vmlinuz         BAD
#   image=vmlinuz                   GOOD
#   image=/vmlinuz                  BAD
#   image=\vmlinuz                  GOOD


sub efi_friendly {
    my $path = shift;
    $path =~ s{/boot/efi/}{/};
    $path =~ s{/}{\\}g;
    return $path;
}

sub strip_path {
    my $path = shift;
    $path =~ s{^.*/}{}g;
    return $path;
}

sub install_loader {
    my $this = shift;
    $this->cleanup_bootlist();
    $this->create_entry();
}

sub create_entry {
    my $this = shift;
    my $bootmgr = $$this{bootmenu_exe};
    my $elilo = $$this{bootloader_exe};
    my $conf = $$this{config_file};
    
    my $efi_elilo = "";
    my $efi_conf = "";

    $_ = $elilo;
    if (m!^/boot/efi(/.*)$!) {
	$efi_elilo = $1;
	$efi_elilo =~ s!/!\\\\!g;
    }
    else {
	croak("elilo.efi must be in a subdirectory of /boot/efi.");
    }
    $_ = $conf;
    if (m!^/boot/efi(/.*)$!) {
	$efi_conf = $1;
	$efi_conf =~ s!/!\\\\!g;
    }
    else {
	croak("elilo.conf must be in a subdirectory of /boot/efi.");
    }

    ## This will check /etc/fstab for the boot
    ## device and partition
    if(!$$this{boot_bootdev}) 
    {
	open(FSTAB, '</etc/fstab');
	while (<FSTAB>) {
	    if (m!\s*(\S*)\s*/boot/efi\s*.*$!) {
		my $boot_partition = $1;
		$boot_partition =~ /^(.+)(\d+)$/;
		if (!$$this{boot_bootdev}) {
		    $$this{boot_bootdev} = $1;
		}
		if (!$$this{boot_bootpart}) {
		    $$this{boot_bootpart} = $2;
		}
	    }
	}
    	close(FSTAB);
    }
    

    my $cmd = "$bootmgr -c ";
    if ($$this{boot_bootdev}) {
	$cmd .= "-d $$this{boot_bootdev} ";
    }
    if ($$this{boot_bootpart}) {
	$cmd .= "-p $$this{boot_bootpart} ";
    }

    $cmd .= "-w -l $efi_elilo -u -- elilo -C $efi_conf";

    if($$this{root}) {
        if($bootmgr =~ /^($$this{root})(.*)/) {
            my $cmd2 = $2;
            $cmd = "chroot $$this{root} $cmd2 -c";
        } 
    }
    verbose("About to run '$cmd'");
    return !system("$cmd > /dev/null 2> /dev/null");
}

sub linux_efi_entries {
    my $this = shift;
    my @linuxentries = ();
    my $cmd = $$this{bootmenu_exe};
    if($$this{root}) {
        if($cmd =~ /^($$this{root})(.*)/) {
            my $cmd2 = $2;
            $cmd = "chroot $$this{root} $cmd2";
        }
    }
    open(IN,"$cmd |") or return ();
    
    while(<IN>) {
        if(/^Boot(\w{4}).*Linux/) {
            push @linuxentries, $1;
        }
    }
    close(IN);
    return @linuxentries;
}

sub cleanup_bootlist {
    my $this = shift;
    my @linuxentries = $this->linux_efi_entries();
    foreach my $entry (@linuxentries) {
        $this->remove_entry($entry);
    }
    return 1;
}

sub remove_entry {
    my ($this, $entry) = @_;

    my $e = $$this{bootmenu_exe};
    my $cmd = "$e -b $entry -B";
    if($$this{root}) {
        if($e =~ /^($$this{root})(.*)/) {
            my $cmd2  = $2;
            $cmd = "chroot $$this{root} $cmd2 -b $entry -B";
        }
    } 
    verbose("About to run '$cmd'\n");
    return !system("$cmd > /dev/null 2> /dev/null");
}

=back

=head1 AUTHOR

  dann frazier <dannf@ldl.fc.hp.com>

=head1 SEE ALSO

L<Boot>, L<perl>

=cut

1;




















