package SCConfig;

#   $Id: SCConfig.pm 708 2007-11-10 00:51:03Z efocht $

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
use Data::Dumper;
use AppConfig qw(:expand :argcount);
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 708 $ =~ /(\d+)/);

my %cfg = (
           CASE => 0,
           # now this is very subtle.  But it turns out that CREATE has the undocumented
           # feature that it really is a %s type.  You can specify a regex for create, and it
           # will apply it to decide if the variable stands to get created.  
           #
           # I had originally set this to 0, which meant that any variable with a 0 in it would
           # get created.  With undef it runs in strict mode as I was originally intending.
          
           CREATE => undef,
           GLOBAL => {
                      DEFAULT => "",
                      ARGCOUNT => ARGCOUNT_ONE,
                     },
          );

my $config = new AppConfig(\%cfg,
                           CFGFILE => {},
                           EXCLUDESTO => {ALIAS => "EXCLUDES-TO"},
			   ROOT => {},
                           MAXKERNEL => {
                                         DEFAULT => 10,
				 }
                          );

# Populate the main set of switches
populate_main_switches($config);

if(!scalar(@ARGV)) {
    $config->set('confignone',1);
}

# First we parse the config file
#
# Parsing order is important, and now I'll say why
#
# 1) parse the argv - this lets argv change the rest of the options (important for overrides)
# 2) stack up the rest of the inputs in the order
#     - global conf
#     - stdin 
#     - user specified config file
#     - argv again (so things on arv get super override ability)
#
# We always want the argv parameters to override anything else 

my @AGAIN = ();
foreach my $arg (@ARGV) {
    unless ($arg =~ /\b(configsi|configall)\b/) {
        push @AGAIN, $arg;
    }
}

# populate the things we can early.  Kernel stuff will have to wait till after the
# first round.

populate_network($config);

populate_hardware($config);

populate_time($config);

populate_userexit($config);

$config->getopt(\@ARGV);

if($config->quiet) {
    $config->{STATE}->{ERROR} = sub {return 1;};
    $config->{STATE}->{EHANDLER} = sub {return 1;};
}

populate_boot($config, $config->maxkernel);

my @args;

if(-e "/etc/systemconfig/systemconfig.conf") {
    push @args, qw(/etc/systemconfig/systemconfig.conf);
}

if($config->stdin()) {
    push @args, \*STDIN;
}

if($config->cfgfile && -e $config->cfgfile()) {
    push @args, $config->cfgfile();
}

if(scalar @args) {
    $config->file(@args);
}

unless ( $config->nocheck() || $config->help() || $config->confignone() ) {
    check_config($config, $config->maxkernel);
}

$config->getopt(\@AGAIN);

#
# Replace special variables in global APPEND block:
# <HOSTID> is replaced with the concatenation of all digits in the HOSTNAME
# Additionally allowed formats:
#   <HOSTID-100>  or <HOSTID+2>
#
if ($config->boot_append) {
    my $append = $config->boot_append;
    if ($append =~ /<HOSTID([^>]*)>/) {
	my $op = $1;
	(my $hid = $ENV{HOSTNAME}) =~ s/\D//g;
	if ($op && ($op =~ m/^(\+|\-)\d+$/)) {
	    eval "\$hid = \$hid $op";
	}
	# strip leading zeros
	$hid = sprintf "%d", $hid;
	$append =~ s/<HOSTID([^>]*)>/$hid/g;
	$config->boot_append($append);
    }
}

$::main::config = $config;

sub populate_main_switches {
    my ($config) = @_;
    my @noargs = qw(stdin verbose debug version help quiet nocheck);
    my @configstages = qw(confignet configboot confighw runboot configrd confignone); 
    my @config_on = qw(configkeyboard configtime configuserexit);

    foreach my $arg (@noargs, @configstages) {
        $config->define($arg => {ARGCOUNT => ARGCOUNT_NONE});
    }
    
    foreach my $arg (@config_on) {
        $config->define($arg => {
                                 DEFAULT => 1,
                                 ARGCOUNT => ARGCOUNT_NONE
                                });
    }
    
    $config->define(
                    configsi => {
                                 DEFAULT => 0,
                                 ARGCOUNT => ARGCOUNT_NONE,
                                 ACTION => sub {
                                     if($config->configsi) {
                                         $config->confignet(1);
                                         $config->confighw(1);
                                         $config->runboot(1);
                                     }
                                 }
                                },
                    configall => {
                                  DEFAULT => 0,
                                  ARGCOUNT => ARGCOUNT_NONE,
                                  ACTION => sub {
                                      if($config->configall) {
                                          $config->confignet(1);
                                          $config->confighw(1);
                                          $config->configrd(1);
                                          $config->configboot(1);
                                          $config->runboot(1);
                                      }
                                  }
                                 }
                   );
}

sub populate_hardware {
    my ($config) = @_;
    $config->define(
                    hardware_order => {},
                   );
    return 1;
}

sub populate_time {
    my ($config) = @_;
    $config->define(
                    time_zone => {},
                    time_utc => {DEFAULT => 1},
                   );
    return 1;
}

sub populate_boot {
    my ($config, $number) = @_;
    $config->define(
                    boot_prefered => {},
                    boot_rootdev => {},
                    boot_bootdev => {},
                    boot_timeout => {},
                    boot_defaultboot => {},
                    boot_append => {},
                    boot_vga => {},
                    boot_extras => {},
                    boot_extras2 => {},
                    boot_extras3 => {},
                   );

    for (my $i = 0; $i < $number; $i++) {
        my $var = "kernel$i"; 
        $config->define(
                        $var . "_path" => {},
                        $var . "_label" => {},
                        $var . "_initrd" => {},
                        $var . "_append" => {},
                        $var . "_rootdev" => {},
			$var . "_hostos" => {},
                       );
    }
}
         
# Handle definitions for all the networking options

sub populate_network {
    my ($config) = @_;
    $config->define(
                    network_shorthostname => {
                                          ARGCOUNT => ARGCOUNT_NONE,
                                          DEFAULT => 0
                                         },
                    network_gateway => {},
                    network_gatewaydev => {},
                    network_hostname => {},
                    network_domainname => {},
                    network_search => {},
                    network_dns1 => {},
                    network_dns2 => {},
                    network_dns3 => {},
                   );

    my @intvars = qw(device type ipaddr netmask);

    my $regex = 'interface\d+_' . (join '|interface\d+_', @intvars);

    if(defined $config->{STATE}->{CREATE}) {
        $config->{STATE}->{CREATE} .= '|' . $regex;
    } else {
        $config->{STATE}->{CREATE} = $regex;
    }
}

sub populate_userexit {
    my ($config) = @_;
    
    my $regex = 'userexit\d+_cmd|userexit\d+_params';

    if(defined $config->{STATE}->{CREATE}) {
        $config->{STATE}->{CREATE} .= '|' . $regex;
    } else {
        $config->{STATE}->{CREATE} = $regex;
    }
}

# Check if files specified in systemconfigurator config actually exists before continuing
sub check_config {
    my ($config, $number) = @_;

    my $boot_rootdev = $config->get('boot_rootdev');
    my $boot_bootdev = $config->get('boot_bootdev');

    unless ( ($boot_rootdev) && ($boot_rootdev =~ /^UUID|^LABEL/) ) {
	if ( $boot_rootdev && ! -e $boot_rootdev ) {
	    print("ROOTDEV $boot_rootdev under [BOOT] does not exist, please check your systemconfigurator config\n");
	    exit 1;
	}
    }

    unless ( ($boot_bootdev) && ($boot_bootdev =~ /^UUID|^LABEL/) ) {
	if ( $boot_bootdev && ! -e $boot_bootdev ) {
	    print("BOOTDEV $boot_bootdev under [BOOT] does not exist, please check your systemconfigurator config\n");
	    exit 1;
	}
    }
    for (my $i = 0; $i < $number; $i++) {
	my $var = "kernel$i"."_path";
	my $kernel = $config->get("$var");

	if ( "$kernel" && ! -e "$kernel" ) {
	    print("Kernel $kernel under [KERNEL$i] does not exist, please check your systemconfigurator config\n");
	    exit 1;
	}
    }
}

=head1 NAME 

SCConfig - AppConfig Macros for systemconfigurator

=head1 SYNOPSIS

  use SCConfig;
  use vars qw($config);

  my $var1 = $config->get('var1');

=head1 DESCRIPTION

SCConfig is just a central location to store all the AppConfig
setup used by the B<systemconfigurator> script.

Upon use, SCConfig parses command line arguments and config files.
It registers a global variable $config into the main name space which is an instance
of AppConfig.

=head1 AUTHORS

Sean Dague <sean@dague.net>
Joe Greenseid <jgreenseid@users.sourceforge.net>
V Hoffman <greekboy@users.sourceforge.net>

=head1 SEE ALSO

L<AppConfig>, L<systemconfigurator>, L<systemconfig.conf>, L<perl>, and
the I<sample.cfg> config file in the systemconfigurator distribution.

=cut

1;
