package Time::Zone;

#   $Id: Zone.pm 664 2007-01-15 21:40:36Z arighi $

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
use Time::Zone::Debian;
use Time::Zone::RH;
use Time::Zone::SuSE8;

use vars qw(@tztypes $VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

# Setup for Timezones is really pretty simple.  There is a file in 
# /usr/share/zoneinfo which is the zoneinfo file.  This file just
# needs to make its way ot /etc/localtime.

 
sub setup {
    my %vars = (
                root => "",
                # Clearly the timezone that Sean lives in should be the defautl :)
                # This actually shouldn't affect anything, as we don't even branch
                # to here unless tz is set, but I thought it would be funny.
                time_zone => "America/New_York",
                time_utc => 1,
                @_,
               );
   
    my @files = ("$vars{root}/etc/localtime");
    glibc_setup(%vars) or return undef;
    
    my @tzfiles = conf_setup(%vars);
    return (@files, @tzfiles);
}

sub glibc_setup {
    my %vars = (
                root => "",
                time_zone => "",
                @_,
               );
    my $source = $vars{root} . "/usr/share/zoneinfo/" . $vars{time_zone};
    my $target = $vars{root} . "/etc/localtime";

    if(-e $source) {
        copy($source, $target) or (carp ("Couldn't copy $source to $target"), return 0);
    } else {
        carp ("Time Zone $vars{time_zone} doesn't appear to exist at $source.");
        return undef;
    }
    return 1;
}

sub conf_setup {
    my %vars = (
                root => "",
                time_zone => "",
                time_utc => 1,
                @_,
               );
    my @files = ();

    foreach my $tztype (@tztypes) {
        my $tz = $tztype->new(%vars);
        if($tz->footprint()) {
            $tz->setup();
            push @files, $tz->files(); 
        }
    }
    return @files;
}

1;
