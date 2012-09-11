package Util::Cmd;
use File::Path;

#   $Id: Cmd.pm 664 2007-01-15 21:40:36Z arighi $

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
use Carp;

require Exporter;
use vars qw(@ISA @EXPORT_OK @EXPORT %EXPORT_TAGS $VERSION);

push @ISA, qw(Exporter);

%EXPORT_TAGS = (
                'all' => [
                          qw(which deltree mkpath)
                         ]
               );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub which {
    my $exename = shift;
    for (map {"$_/$exename"} split(/:/,$ENV{PATH})) {
        return $_ if(-e and -x);
    }
}

sub deltree {
    rmtree([@_]);
}


1;
__END__

=head1 NAME

Util::Cmd - Additional Unix Commands needed by SC

=head1 SYNOPSIS

  use Util::Cmd qw(:all);
  my $grubpath = which('grub');
  deltree("/tmp/file1");
  deltree("/tmp/directory");
  mkpath("/tmp/tmp2/tmp3");

=head1 DESCRIPTION

Exports I<which()>, I<deltree()> and I<mkpath()> functions.  

I<which> takes an executable and returns the path to it. 

I<deltree> recursively deletes files and directories given a list of
such files and directories.

Note: I<deltree> does not recognize shell metacharacters such as "*"
and "?" so if you want do send it a list of files use something like:

deltree(glob("files*"));

I<mkpath> takes a directory and creates it, along with all the intermediate directories as needed.  Acts exactly like "mkdir -p".

=head2 EXPORT

None by default.  With the I<:all> specification I<which>, I<deltree>,
and I<mkpath> are exported.

=head1 AUTHOR

  Sean Dague <sean@dague.net>
  Vasilios Hoffman <greekboy@users.sourceforge.net>

=head1 SEE ALSO

L<perl>.

=cut
