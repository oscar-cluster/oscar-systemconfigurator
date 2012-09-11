package Util::FileMod;

#   $Id: FileMod.pm 687 2007-09-19 19:01:34Z bli $

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

#   Sean Dague <sean@dague.net>

use strict;
use Carp;
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 687 $ =~ /(\d+)/);

=head1 NAME

Util::FileMod - A flexible interface for modifying simple flat text config files.

=head1 SYNOPSIS

# for space seperated, unquoted key/value files, like modules.conf

my $rc = new Util::FileMod(Seperator => ' ', Quotes => '', Comment => '#');

$rc->add_vars(
              "alias eth0" => "eepro100",
              "alias eth1" => "pcnet32",
              "alias tr0" => "olympic",
                );

$rc->update_file("/mnt/etc/modules.conf");

# for '=' seperated, double quoted key/value files, like the suse rc.config file
# and most rc files

my $rc = new Util::FileMod(Seperator => '=', Quotes => '"', Comment => '#');

$rc->add_vars(
              IPADDR_0 => "192.168.64.101",
              NETDEV_0 => "eth0",
              IFCONFIG_0 => "192.168.64.101  broadcast 192.168.64.255 netmask 255.255.255.0",
              NETCONFIG => "_0",
             );

$rc->update_file("/mnt/etc/rc.config");

# Note:  Defaults to Seperator => '=', Quotes => '"', Comment => '#'

=cut

sub new {
    my $class = shift;
    my $this = {  
                Seperator => '=',
                Quotes => '"',
                Comment => '#',
                @_,
                filesmod => [],
               };

    bless $this, $class;
}

sub files {
    my $this = shift;
    return @{$this->{filesmod}};
}

sub append_vars {
    my $this = shift;
    my %vars = @_;
    foreach my $key (keys %vars) {
        $this->{VARS}->{$key}->{VALUE} .= $vars{$key};
    }
    return 1;
}

sub add_vars {
    my $this = shift;
    my %vars = @_;
    foreach my $key (keys %vars) {
        $this->{VARS}->{$key}->{VALUE} = $vars{$key};
    }
    return 1;
}

sub update_file {
    my $this = shift;
    my $file = shift;
    
    if(-e $file) {
        system("cp $file $file.scbak") and croak("Couldn't backup $file to $file.scbak");
        open(IN,"<$file.scbak") or croak("Could not open $file.scbak for reading");
        open(OUT,">$file") or croak("Could not open $file for writing");
    
        while(<IN>) {
            my $line = $this->new_line($_);
            print OUT $line;
        }
        close(IN);
    } else {
        open(OUT,">$file") or croak("Could not open $file for writing");
    }

    if (my $extra = $this->extra_lines()) {
        print OUT $extra;
    }
    close(OUT);

    push @{$this->{filesmod}},$file,"$file.scbak";

    return 1;
}

sub extra_lines {
    my $this = shift;
    my $lines;

    my $quotes=$this->{Quotes};
    my $sep = $this->{Seperator};
    my $rem = $this->{Comment}; #hehe, "rem" brings back memories!

    foreach my $key (sort keys %{$this->{VARS}}) {
        if (!$this->{VARS}->{$key}->{DONE}) {
            my $value = $this->{VARS}->{$key}->{VALUE};
            $lines .= "$key$sep$quotes$value$quotes\n";
            $this->{VARS}->{$key}->{DONE} = 1;
        }
    }

    if (defined $lines) {
        $lines = "$rem BEGIN: Lines added by System Configurator\n" . $lines;
        $lines .= "$rem END: Lines added by System Configurator\n";
    }

    return $lines;
}

sub new_line {
    my $this = shift;
    my $line = shift;

    my $quotes=$this->{Quotes};
    my $sep = $this->{Seperator};
    my $rem = $this->{Comment}; #hehe, "rem" brings back memories!

    foreach my $key (sort keys %{$this->{VARS}}) {
        my $value = $this->{VARS}->{$key}->{VALUE};
        $value =~ s/\s+$//;
        my $message = "$rem This line commented out by System Configurator\n";
        my $newline = "$key$sep$quotes$value$quotes\n";
        if($line =~ /^($key($sep)+.*)/) {
            my $oldine = " " . $1 . "\n";
            if($1 eq $newline) {
                $this->{VARS}->{$key}->{DONE} = 1;
                return $line;
            } else {
                $this->{VARS}->{$key}->{DONE} = 1;
                $line = $message . $rem . $oldine . $newline;
                return $line;
            }
        }
    }
    return $line;
}

1;
