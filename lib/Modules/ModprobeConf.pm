package Modules::ModprobeConf;

#   $Id: ModprobeConf.pm 664 2007-01-15 21:40:36Z arighi $

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

Modules::ModprobeConf - setup for modprobe.conf

=head1 SYNOPSIS

 my $modulesconf = new Modules::ModprobeConf(%vars);

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

push @Hardware::conftypes, qw(Modules::ModprobeConf);

sub new {
    my $class = shift;

    my %vars = @_;

    my %this = (
                _root => $vars{root},
                _postcommand => "",
                _otherfiles => [],
                _filesmod => [],
                _modulesfile => "/etc/modprobe.conf",
                _footprints => [qw(/etc/modprobe.conf /etc/modprobe.conf.dist)],
               );
    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item footprint()

This method returns 1 if B</etc/modprobe.conf> is being used on the machine.
The test succeeds and returns 1 in two cases:
Case 1: /etc/modprobe.conf exists B<and> /etc/modutils/aliases does not exist.

Otherwise, this method will return undef.

=cut

sub footprint {
    my $this = shift;
    my $nofile = $this->chroot("/etc/modutils/aliases");
    if(-e $nofile) {
        return undef;
    }
    # if any of these exist, we're home
    foreach my $f (@{$this->{_footprints}}) {
        my $file = $this->chroot($f);
        if(-e $file) {
            return 1;
        }
    }
    # nothing found, move on
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
