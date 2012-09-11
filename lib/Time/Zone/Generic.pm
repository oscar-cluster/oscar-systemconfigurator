package Time::Zone::Generic;

#   $Id: Generic.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2002 International Business Machines

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
use Data::Dumper;
use vars qw($VERSION $AUTOLOAD @ISA);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub new {
    my $class = shift;
    my %this = (
                _root => "",
                _zone => "",
                _utc => "",
                _filesmod => [],
               );
    
    my %config = @_;

    $this{_root} = $config{root};

    foreach my $item (qw(zone utc)) {
        $this{"_" . $item} = $config{"time_" . $item};
    }
    
    bless \%this, $class;
}

sub files {
    my $this = shift;
    if (scalar(@_) > 0) {
        push @{$this->{_filesmod}}, @_;
    }
    return @{$this->filesmod};
}

sub footprint {
    my $this = shift;
    croak("Danger Will Robinson... footprint must be implemented by the subclass!");
}

sub setup {
    my $this = shift;
    croak("Danger Will Robinson... setup must be implemented by the subclass!");
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

# Default Autoloader.  Means we don't have to define accessors for private data.
# This can probably be made more efficient through method caching, but
# I haven't gotten arround to it yet.

sub AUTOLOAD {
    my ($this) = @_;
    $AUTOLOAD =~ /.*::(\w+)/
      or croak("No such method: $AUTOLOAD");
    my $var = $1;

    exists $this->{"_$var"}
      or croak("No such method: $AUTOLOAD");
    
    return $this->{"_$var"};
}

42;
