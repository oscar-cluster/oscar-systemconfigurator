package UserExit;

#   $Id: UserExit.pm 664 2007-01-15 21:40:36Z arighi $

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

use vars qw($VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

# Ok, so we are going to go in 2 passes, first setup TimeZone, then do network
# time things
 
sub setup {
    my $config = shift;
    my %userexits = $config->varlist("^(root|userexit)");
    
    # compile the list of user exits
    my @exitnames = ();
    foreach my $key (sort keys %userexits) {
        if($key =~ /^(userexit\d+)_cmd$/ and $userexits{$key}) {
            push @exitnames, $1;
        }
    }
    foreach my $exit (@exitnames) {
        if(!my_system($userexits{root}, $userexits{"$exit" . "_cmd"}, $userexits{"$exit" . "_params"})) {
            carp("Couldn't run " . $userexits{"$exit" . "_cmd"} . " " .  $userexits{"$exit" . "_params"});
            return 0;
        }
    }
    return 1;
}

sub my_system {
    my ($root, $cmd, $params) = @_;
    my $abscmd = my_which($root, $cmd);
    if(!$abscmd) {
        carp("Command $cmd not found.  Skipping...");
        return 1;
    }
    my $cmdtorun = $abscmd;
    
    if($params) {
	    $cmdtorun .= " $params";
    }
    
    if($root) {
        $cmdtorun = "chroot $root " . $cmdtorun; 
    }
    return !system($cmdtorun);
}

sub my_which {
    my ($root, $cmd) = @_;

    # is it absolute?  Then test if it exists
    if($cmd =~ /\//) {
        if($root) {
            if(-x "$root/$cmd") {
                return $cmd;
            }
        } else {
            if(-x $cmd) {
                return $cmd;
            }
        }
    } else {
        # if it is relative, we figure out where it is located
        if($root) {
            my @possibles = map {"$root/$_/$cmd"} split(/:/,$ENV{PATH});
            foreach my $poss (@possibles) {
                if(-x $poss) {
                    $poss =~ s/^$root//;
                    return $poss;
                }
            }
        } else {
            my @possibles = map {"$_/$cmd"} split(/:/,$ENV{PATH});
            foreach my $poss (@possibles) {
                if(-x $poss) {
                    return $poss;
                }
            }
        }
    }

    # If we got this far, it means the command was not found
    return undef;
}
1;
