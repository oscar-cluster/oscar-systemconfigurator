package Modules::ConfModules;

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

Modules::ConfModules - setup for conf.modules

=head1 SYNOPSIS

 my $confmodules = new Modules::ConfModules(%vars);

 if ($confmodules->footprint()) {
      $confmodules->setup();
 }

 my @fileschanged = $confmodules->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use base qw(Modules::Generic);
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Hardware::conftypes, qw(Modules::ConfModules);

sub new {
    my $class = shift;

    my %vars = @_;

    my %this = (
                _root => $vars{root},
                _postcommand => "",
                _otherfiles => [],
                _filesmod => [],
                _modulesfile => "/etc/conf.modules",
               );
    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if B</etc/conf.modules> is being used on the machine.
The test is if B</etc/conf.modules> exists B<and> if B</etc/modules.conf> 
does not exists.  If either of these are untrue, the method will return undef.

=cut

sub footprint {
    my $this = shift;
    my $file = $this->chroot("/etc/conf.modules");
    my $nofile = $this->chroot("/etc/modules.conf");
    if((-e $file) && (!-e $nofile)) {
        return 1;
    }
    return undef;
}

=back

=head1 AUTHORS

  Sean Dague <sean@dague.net>
  Joe Greenseid <jgreenseid@users.sourceforge.net>

=head1 SEE ALSO

L<SystemConifg::Hardware>, L<Util::FileMod>, L<perl>

=cut

1;
