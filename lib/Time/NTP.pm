package Time::Rdate;

#   $Id: NTP.pm 664 2007-01-15 21:40:36Z arighi $

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
use Util::FileMod;

use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

# Ok, so we are going to go in 2 passes, first setup TimeZone, then do network
# time things

push @Time::nettime, qw(Time::NTP);

sub new {
    my $class = shift;
    my %vars = (
                root => "",
                server => "",
                @_,
                exe => which('ntpd'),
                config => "/etc/ntp.conf",
               );
    return bless $class, \%vars;
}

sub footprint {
    my $this = shift;
    return $this->{exe};
}

sub setup {
    my $this = shift;
    my $file = $this->{root} . $this->{config};
    
    my $ntpfile = new Util::FileMod(Seperator => ' ', Quotes => '', Comment => '#');
    
    $ntpfile->add_vars(
                       server => $this->{server},
                      );

    $ntpfile->update_file($file);
    push @{$this->{filesmod}}, $file;

    return 1;
}

sub files {
    my $this = shift;
    return $this->{filesmod};
}

1;
