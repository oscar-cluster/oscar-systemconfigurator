package Time::Rdate;

#   $Id: Rdate.pm 664 2007-01-15 21:40:36Z arighi $

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
use File::Copy;
use Util::Cmd qw(which);

use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

# Ok, so we are going to go in 2 passes, first setup TimeZone, then do network
# time things

push @Time::nettime, qw(Time::Rdate);

sub new {
    my %vars = (
                root => 
               )
}

sub setup {
    my %vars = (
                root => "",
                tz => "",
               );
    
    my $source = $vars{root} . "/usr/share/zoneinfo/" . $vars{tz};
    my $target = $vars{root} . "/etc/localtime";

    if(-e $source) {
        copy($source, $target) or (carp ("Couldn't copy $source to $target"), return undef);
    } else {
        carp ("Time Zone $vars{tz} doesn't appear to exist at $source.");
        return undef;
    }
    return 1;
}

1;
