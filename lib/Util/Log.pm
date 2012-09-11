package Util::Log;

#   $Id $

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

use strict;

require Exporter;
use vars qw(@ISA @EXPORT_OK @EXPORT %EXPORT_TAGS $VERSION $DEBUG $VERBOSE $FH);

push @ISA, qw(Exporter);

%EXPORT_TAGS = ( 
                'all' => [
                          qw(debug verbose start_debug start_verbose stop_debug stop_verbose logger_file)
                         ],
                'print' => [ 
                            qw(debug verbose) 
                           ],
                'control' => [
                              qw(start_debug start_verbose stop_debug stop_verbose logger_file)
                             ],
               );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

$VERSION = sprintf("%d", q$Revision: 681 $ =~ /(\d+)/);

# The following are encapsulated so that we can change the internals without having to change
# code that uses it

{
    $DEBUG = 0;
    $VERBOSE = 0;
    $FH = \*STDERR;
    
    sub start_debug {
        $DEBUG = 1;
    }
    
    sub stop_debug {
        $DEBUG = 0;
    }
    
    sub start_verbose {
        $VERBOSE = 1;
    }

    sub stop_verbose {
        $VERBOSE = 0;
    }
    
    sub logger_file {
        my $fh = shift;
        $FH = $fh;
    }
    
    sub debug {
        if($DEBUG) {
            my ($package, $filename, $line) = caller;
            print $FH "[$package :: Line $line] " . join(', ', @_) . "\n";
        }
    }
    
    sub verbose {
        if($VERBOSE) {
            my ($package, $filename, $line) = caller;
            print $FH &timestamp . " [$package :: Line $line] " . join(', ', @_) . "\n";
        }
    }
    
    sub timestamp {
        my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
        $mon++;
        $year=$year+1900;
        return "$year-$mon-$mday $hour:$min:$sec";
    }
}

1;
__END__

=head1 NAME

Util::Log - Logging mechanism for SystemConfigurator

=head1 SYNOPSIS

  use Util::Log qw(:print);
  my $grubpath = which('grub');

=head1 DESCRIPTION

This only exports the which() function at this point.  Other functions may be placed 
here in the future as well.

=head2 EXPORT

None by default.  With the I<:all> specification I<which> is exported.

=head1 AUTHOR

  Sean Dague <sean@dague.net>

=head1 SEE ALSO

L<perl>.

=cut
