package Keyboard;

#   $Id: Keyboard.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2002-2003 International Business Machines

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
use Util::FileMod;
use Data::Dumper;

use vars qw(@keytypes $VERSION);

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub setup {
    my $config = shift;
    
    my $rcconfig = $config->root . "/etc/rc.config";

    if(file_grep('KEYTABLE',$rcconfig)) {
        suse_keyboard_english($config, $rcconfig);
    }
    return 1;
}

sub suse_keyboard_english {
    my ($config, $rcconfig) = @_;
    my $rcfile = new Util::FileMod(Seperator => '=', Quotes => '"');
    $rcfile->add_vars("KEYTABLE" => '');
    $rcfile->update_file($rcconfig);
    return 1;
}

sub file_grep {
    my ($term, $file) = @_;
    local $/ = undef;
    open(IN,"<$file") or return undef;
    my $lines = <IN>;
    close(IN);
    
    if($lines =~ /$term/) {
        return 1;
    }
    return 0;
}

1;

__END__





