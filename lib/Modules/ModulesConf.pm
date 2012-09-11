package Modules::ModulesConf;

#   $Id: ModulesConf.pm 664 2007-01-15 21:40:36Z arighi $

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

Modules::ModulesConf - setup for modules.conf

=head1 SYNOPSIS

 my $modulesconf = new Modules::ModulesConf(%vars);

 if ($modulesconf->footprint()) {
      $modulesconf->setup();
 }

 my @fileschanged = $modulesconf->files();

=head1 DESCRIPTION

=cut

use strict;
use Carp;
use base qw(Modules::Generic);
use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

push @Hardware::conftypes, qw(Modules::ModulesConf);

sub new {
    my $class = shift;

    my %vars = @_;

    my %this = (
                _root => $vars{root},
                _postcommand => "",
                _otherfiles => [],
                _filesmod => [],
                _modulesfile => "/etc/modules.conf",
               );
    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if B</etc/modules.conf> is being used on the machine.
The test succeeds and returns 1 in two cases:
Case 1: /etc/modules.conf exists B<and> /etc/modutils/aliases does not exist.
Case 2: /etc/conf.modules B<and> /etc/modutils/aliases both do not exist.

Otherwise, this method will return undef.

=cut

sub footprint {
    my $this = shift;
    my $file = $this->chroot("/etc/modules.conf");
    my $nofile = $this->chroot("/etc/modutils/aliases");
    my $antifile = $this->chroot("/etc/conf.modules");
    if((-e $file) && (!-e $nofile)) {
        return 1;
    }
    if((!-e $antifile) && (!-e $nofile)) {
        return 1;
    }
    return undef;
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>
  Joe Greenseid <jgreenseid@users.sourceforge.net>

=head1 SEE ALSO

L<Hardware>, L<Util::FileMod>, L<perl>

=cut

1;
