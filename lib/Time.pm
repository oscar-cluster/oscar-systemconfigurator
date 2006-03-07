package Time;

#   $Id: Time.pm,v 1.5 2003/01/07 23:06:05 sdague Exp $

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
use Time::Zone;
#use Time::NTP;
#use Time::Rdate;

use vars qw(@nettime $VERSION);

$VERSION = sprintf("%d.%02d", q$Revision: 1.5 $ =~ /(\d+)\.(\d+)/);

# Ok, so we are going to go in 2 passes, first setup TimeZone, then do network
# time things
 
sub setup {
    my $config = shift;
    my @files = ();
    my %timevars = $config->varlist("^(time|root)");
    if($timevars{time_zone} and $config->configtime) {
        @files = Time::Zone::setup(%timevars);
        if(!scalar(@files)) {
            carp("Couldn't setup Time Zone $timevars{time_zone}");
            return undef;
        }
    }

    # And now, we do network time, in order, stopping after
    # one works

    foreach my $type (@nettime) {
        my $nettime = $type->new(%timevars);
        if($nettime->footprint()) {
            if($nettime->setup()) {
                push @files, $nettime->files(); 
                last;
            }
        }
    }
    return @files;
}

1;
