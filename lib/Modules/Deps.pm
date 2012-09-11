package Modules::Deps;

#   $Id: Deps.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001-2002 International Business Machines

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
use Util::Log qw(:all);
use base qw(Exporter);
use vars qw($VERSION @EXPORT);

@EXPORT = qw(get_deps uniq);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub get_deps {
    my ($version, $module) = @_;
    verbose("Getting kernel dependancies for kernel $version");
    my $file = "/lib/modules/$version/modules.dep";
    my @deps = lookup_deps($file,$module);
    my @left = @deps;
    while(my $mod = shift(@left)) {
        my @tmp = lookup_deps($file,$mod);
        unshift @deps, @tmp;
        push @left, @tmp;
    }
    return uniq(@deps);
}

sub lookup_deps {
    my ($file, $module) = @_;
    my @deps  = ();
    open(IN,"<$file") or (carp "Couldn't open $file for modules.dep analysis", return ());
    my $line = "";
    while(<IN>) {
        if(/\/$module.o(.gz)?:\s+(.+)/) {
            verbose("Found line for $module");
            # I don't think $1 gets set if .gz is missing, hence the following
            my $line = ($2) ? $2 : $1;
            my $last = $line;
            $line =~ s/\\*\s*$//;
            while($last =~ /\\\s*$/) {
                my $more = <IN>;
                $last = $more;
                $more =~ s/\\*\s*$//;
                $line .= $more;
            }
            push @deps, parse_deps($line);
        }
    }
    close(IN);
    return @deps;
}

sub parse_deps {
    my $line = shift;
    my @modules = ();
    my @lines = split(/\s+/,$line);
    foreach my $l (@lines) {
        if($l =~ /([^\/]+).o(.gz)?$/) {
            push @modules, $1;
        }
    }
    return @modules;
}

sub uniq {
    my @list = @_;
    my @newlist = ();
    my %hash = ();
    for (@list) {
        next if $hash{$_};
        push @newlist, $_;
        $hash{$_}++;
    }
    return @newlist;
}

1;
