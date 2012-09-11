package Network::RCConfig;

#   $Id: RCConfig.pm 664 2007-01-15 21:40:36Z arighi $

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

=head1 NAME

Network::RCConfig - rc.config Networking Module

=head1 SYNOPSIS

  my $networking = new Network::RCConfig(%vars);

  if($networking->footprint()) {
      $networking->setup();
  }

  my @fileschanged = $networking->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use vars qw($VERSION);
use base qw(Network::Generic);
use Util::FileMod;

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Network::nettypes, qw(Network::RCConfig);

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if RCConfig networking was discovered on the machine,
undef if it was not.  The current test checks for the existance of
B<$chroot/etc/rc.config>.

=cut

sub footprint {
    my $this = shift;
    my $file = $this->chroot("/etc/rc.config");
    if(-e $file) {
        return 1;
    }
    return undef;
}

=item setup()

The setup method sets up the files for RCConfig networking.
It calls setup_gateway(), setup_interfaces(), and
setup_hostname().

=cut

sub setup_global {
    my $this = shift;

    if ($this->gateway) {
        my $gwfile = $this->chroot("/etc/route.conf");
        open(GW,">$gwfile") or croak("Couldn't open $gwfile for writing");
        print GW "default ", $this->gateway,"\n";
        close(GW);
        $this->files($gwfile);
    }
    if ($this->hostname) {
        my $hostsfile = $this->chroot("/etc/HOSTNAME");
        open(HN,">$hostsfile") or croak("Couldn't open $hostsfile for writing");
        print HN $this->hostname,"\n";
        close(HN);
        $this->files($hostsfile);
    }

    return 1;
}

=item setup_interfaces() 

This determins what interfaces are supposed to be set up and then 
attempts to setup each one in turn.

It does this by searching through the attributes of the RCConfig instance
searching for keys which look like interface\d+_device (i.e. interface0_device).

It then passes the interface\d+ part of that to the setup_interface() method,
and captures the config hash built for each interface.

It uses an instance of Util::FileMod to modify the rc.config
file in place.

=cut

sub setup_interfaces {
    my $this = shift;

    my $rcfile = new Util::FileMod(Seperator => '=', Quotes => '"');
    my $file = $this->chroot("/etc/rc.config");

    my $number = 0;
    
    foreach my $interface (@{$this->interfaces}) {
        my $vars = $this->setup_interface($number, $interface);
        $rcfile->add_vars(%$vars);
        $rcfile->append_vars(NETCONFIG => "_$number ");
        $number++;
    }

    if ($this->hostname) {
        $rcfile->add_vars("FQHOSTNAME" => $this->hostname . "." . $this->domainname);
    }

    $rcfile->update_file($file);
    return 1;
}

=item setup_interface($number, $interface) 

This creates the variables for the Util::FileMod file instance to modify
/etc/rc.config for each interface.  $number is the rc.config interface
number that should be used.

If $interface_type is 'static', and $interface_ip exists, it will set up all the appropriate
settings for static ip addresses.  NETMASK will be either the value specified in 
$interface_netmask, or the appropriate default for the ip address specified.

If $interface_type is 'bootp', the interface is setup of for bootp.

Otherwise the interface is setup for B<dhcp>.

=cut

sub setup_interface {
    my ($this, $number, $interface) = @_;

    my %vars;
    $vars{"NETDEV_$number"} = $interface->device;
    
    if(($interface->type eq "static") and
       $interface->ipaddr and
       $interface->netmask)  {
        
        $vars{"IPADDR_$number"} = $interface->ipaddr;
        $vars{"IFCONFIG_$number"} = $interface->ipaddr . " broadcast " . 
          $interface->broadcast . " netmask " . $interface->netmask;
        
    } elsif ($interface->type eq "bootp") {
        $vars{"IFCONFIG_$number"} = "bootp";
    } else {
        $vars{"IFCONFIG_$number"} = "dhcpclient";
    }
    return \%vars;
}

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConifg::Network>, L<Net::Netmask>, L<Util::FileMod>, L<perl>

=cut

1;
