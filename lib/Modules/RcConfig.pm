package Modules::RcConfig;

#   $Id: RcConfig.pm 664 2007-01-15 21:40:36Z arighi $

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

=head1 NAME

Modules::RcConfig - setup for /etc/rc.config for kernel modules

=head1 SYNOPSIS

 my $aliases = new Modules::RcConfig(%vars);

 if ($aliases->footprint()) {
      $aliases->setup();
 }

 my @fileschanged = $aliases->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use base qw(Modules::Generic);
use Modules::Root;
use Util::FileMod;
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Hardware::conftypes, qw(Modules::RcConfig);

sub new {
    my $class = shift;

    my %vars = @_;

    my %this = (
                _root => $vars{root},
                _postcommand => "/sbin/SuSEconfig",
                _otherfiles => ["$vars{root}/etc/modules.conf"],
                _filesmod => [],
                _configfile => "/etc/rc.config",
               );
    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if both B</etc/modutils/aliases> and 
B</sbin/update-modules> exist on the machine.
Otherwise, it returns undef.

=cut

sub footprint {
    my $this = shift;
    my $file = $this->chroot("/etc/rc.config");
    my $file2 = $this->chroot("/sbin/SuSEconfig");
    my $file3 = $this->chroot("/etc/sysconfig/kernel");
    if(-e $file && -e $file2 && !-e $file3) {
        return 1;
    }
    return undef;
}

sub setup {
    my $this = shift;
    my @aliases = @_;
    my @modules = ();
    my $verbose = ($::VERBOSE) ? "" : " 1>/dev/null 2>/dev/null ";
    # first, get all the aliases as per before
    
    foreach my $alias (@aliases) {
        if($alias->[0] =~ /scsi/) {
            push @modules, $alias->[1];
        }
    }
  
    # second get the root fs modules
    
    push @modules, get_root_fs_modules($this->chroot('/etc/fstab'));
 
    if(scalar(@modules)) {
        my $rc = new Util::FileMod(Seperator => '=', Quotes => '"', Comment => '#');
        $rc->add_vars("INITRD_MODULES" => join(' ',@modules));
        $rc->update_file($this->chroot("/etc/rc.config"));
        
        if ($this->root) {
            system("chroot " . $this->root . " " . $this->postcommand . $verbose);
        } else {
            system($this->postcommand . $verbose);
        }
    }
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<SystemConifg::Hardware>, L<Util::FileMod>, L<perl>

=cut

1;
