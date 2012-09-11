package Modules::ModutilsAliases;

#   $Header$

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

Modules::ModutilsAliases - setup for /etc/modutils/aliases

=head1 SYNOPSIS

 my $aliases = new SysemConfig::Kernel::ModutilsAleases(%vars);

 if ($aliases->footprint()) {
      $aliases->setup();
 }

 my @fileschanged = $aliases->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use base qw(Modules::Generic);
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Hardware::conftypes, qw(Modules::ModutilsAliases);

sub new {
    my $class = shift;

    my %vars = @_;

    my %this = (
                _root => $vars{root},
                _postcommand => "/sbin/update-modules",
                _otherfiles => ["$vars{root}/etc/modules.conf"],
                _filesmod => [],
                _modulesfile => "/etc/modutils/aliases",
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
    my $file = $this->chroot("/etc/modutils/aliases");
    my $file2 = $this->chroot("/sbin/update-modules");
    if(-e $file && -e $file2) {
        return 1;
    }
    return undef;
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>
  Joe Greenseid <jgreenseid@users.sourceforge.net>

=head1 SEE ALSO

L<SystemConifg::Hardware>, L<Util::FileMod>, L<perl>

=cut

1;
