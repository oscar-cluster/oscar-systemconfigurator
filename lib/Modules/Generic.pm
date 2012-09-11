package Modules::Generic;

#   $Id: Generic.pm 664 2007-01-15 21:40:36Z arighi $

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

Modules::Generic - Generic modules setup function

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
use Util::FileMod;
use vars qw($VERSION $AUTOLOAD);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub new {
    my $class = shift;
    my %this = (
                _modulesfile => "",
                _otherfiles => [],
                _postcommand => "",
                _root => "",
                _filesmod => [],
                @_,
               );
    bless \%this, $class;
}

=head1 METHODS

The following methods exist in this module:

=over 4

=item files()

The files method is merely an accessor method for the all files
touched by the instance during its run.

=cut

sub files {
    my $this = shift;
    if (scalar(@_) > 0) {
        push @{$this->filesmod}, @_;
    }
    return @{$this->filesmod};
}

sub chroot {
    my $this = shift;
    if (!$this->root) {
        return shift;
    } else {
        my $var = shift;
        return $this->root . $var;
    }
}

sub DESTROY {
    # This makes sure that AUTOLOAD doesn't bitch on trying to call DESTROY
    return 1;
}

sub AUTOLOAD {
    my ($this) = @_;
    $AUTOLOAD =~ /.*::(\w+)/
      or croak("No such method: $AUTOLOAD");
    exists $this->{"_" . $1}
      or croak("No such attribute: $1");
    return $this->{"_" . $1};
}

=item footprint()

Otherwise, this method will return undef.

=cut

sub footprint {
    my $this = shift;
    croak("Footprint must be defined in the subclass");
}

=item setup()

The setup method sets up the B</etc/modules.conf> file for use.

=cut

sub setup {
    my $this = shift;
    my @aliases = @_;

    my $file = $this->chroot($this->modulesfile);

    my $mcfile = Util::FileMod->new(Seperator => ' ', Quotes => '');
    
    for(my $i = 0; $i < scalar(@aliases); $i++) {
        my $item = $aliases[$i];
        $mcfile->add_vars("alias $$item[0]" => $$item[1]);
    }
    
    $mcfile->update_file($file);

    if ($this->postcommand) {
        if ($this->root) {
            system("chroot " . $this->root . " " . $this->postcommand);
        } else {
            system($this->postcommand);
        }
    }

    $this->files($file, @{$this->otherfiles});
    return 1;
}

=back

=head1 AUTHOR

  Sean Dague <sean@dague.net>
  Joe Greenseid <jgreenseid@users.sourceforge.net>

=head1 SEE ALSO

L<SystemConifg::Hardware>, L<Util::FileMod>, L<perl>

=cut

1;
