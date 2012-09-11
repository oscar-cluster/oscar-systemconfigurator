package Network::LinuxConf;

#   $Id: LinuxConf.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001-2003 International Business Machines

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

#   Note: The naming of this module LinuxConf was based on the fact
#   that most distributions which used this type of networking used to
#   use LinuxConf for their network Configuration.  This is no longer
#   the case, and the module should probably be renamed RH or
#   something to more accurately state what it does.  But that
#   requires effort, and the code still does everything it should do.

=head1 NAME

Network::LinuxConf - Linux Conf Networking Module

=head1 SYNOPSIS

  my $networking = new Network::LinuxConf(%vars);

  if($networking->footprint()) {
      $networking->setup();
  }

  my @fileschanged = $networking->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use Data::Dumper;
use vars qw($VERSION);
use base qw(Network::Generic);
use Util::FileMod;

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Network::nettypes, qw(Network::LinuxConf);

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if LinuxConf networking was discovered on the machine,
undef if it was not.  The current test checks for the existance of
B<$chroot/etc/sysconfig/network-scripts/ifup>.

=cut

sub footprint {
    my $this = shift;

    my $file = $this->chroot("/etc/sysconfig/network-scripts");
    if(-d $file) {
        return 1;
    }
    return undef;
}

=item setup_interface($interface) 

This sets up the ifcfg-$dev files.  It assumes that it has free reign of these files,
which should be valid except for some fairly esoteric networking configurations.

It sets ONBOOT to yes, DEVICE to $interface_device (as specified in the config
file).

If $interface_type is 'static', and $interface_ip exists, it will set up all the appropriate
settings for static ip addresses.  NETMASK will be either the value specified in 
$interface_netmask, or the appropriate default for the ip address specified.

If $interface_type is 'bootp', the interface is setup of for bootp.

Otherwise the interface is setup for B<dhcp>.

=cut

sub setup_interface {
    my ($this, $interface) = @_;

    my $file = $this->chroot("/etc/sysconfig/network-scripts/ifcfg-" . $interface->device);
    
    open(OUT,">$file") or croak("Couldn't open $file for writing");
    
    my $device = $interface->device;
    my $type = $interface->type;
    if ($type eq "static" and $interface->ipaddr and $interface->netmask) {
        my $ipaddr = $interface->ipaddr;
        my $netmask = $interface->netmask;
        my $network = $interface->network;
        my $broadcast = $interface->broadcast;
        
        print OUT <<EOF;
DEVICE="$device"
ONBOOT="yes"
BOOTPROTO="none"
IPADDR="$ipaddr"
NETMASK="$netmask"
NETWORK="$network"
BROADCAST="$broadcast"
EOF
  
    } elsif ($type eq "bootp") {
        print OUT <<EOF;
DEVICE="$device"
ONBOOT="yes"
BOOTPROTO="bootp"
EOF

   } else {
       print OUT <<EOF;
DEVICE="$device"
ONBOOT="yes"
BOOTPROTO="dhcp"
EOF

    }
    $this->files($file);
}

=item setup_global 

setup_global sets up the default gatway, and the host/domain names
via modification of B</etc/sysconfig/network>.  It does not assume that it owns
this file.  If the file already exists it will move it to B</etc/systconfig/network.scbak> 
first, then create the new file by modifying the lines from the old file that it needs to.

If it creates a new file it will create a file with NETWORKING, FORWARD_IPV4,
GATEWAY, HOSTNAME, and DOMAINNAME.  NETWORKING will default to 
"yes" and FORWARD_IPV4 will default to "no".

=cut

sub setup_global {
    my $this = shift;
    my $networkfile = $this->chroot("/etc/sysconfig/network");
    my $rcfile = new Util::FileMod(
                                                 Seperator => '=', 
                                                 Quotes => ''
                                                );
    my $somethingtodo = 0;
    # Make sure the NETWORKING line is there. This could check
    # if its there already, but probably overkill.
    $rcfile->add_vars("NETWORKING" => "yes");
    $somethingtodo++;

    if ($this->gateway) {
        $rcfile->add_vars("GATEWAY" => $this->gateway);
        $rcfile->add_vars("GATEWAYDEV" => $this->gatewaydev);
        $somethingtodo++;
    }
    if ($this->hostname) {
        my $hostname = $this->hostname;
        if($this->domainname and !$this->shorthostname) {
            $hostname .= "." . $this->domainname;
        }
        $rcfile->add_vars("HOSTNAME" => $hostname);
        $somethingtodo++;
    }
    if ($this->domainname) {
        $rcfile->add_vars("DOMAINNAME" => $this->domainname);
        $somethingtodo++;
    }
    
    if ($somethingtodo) {
        $rcfile->update_file($networkfile);
        $this->files($networkfile);
    }

    return 1;
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConifg::Network>, L<Net::Netmask>, L<perl>

=cut

1;
