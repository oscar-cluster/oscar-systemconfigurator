use Test;
use Util::Log;
use Data::Dumper;
use Carp;

#
# This test is to
#

BEGIN {
    
    # Set up tests to run
    
    plan tests => 10;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--root /tmp/sctests --time_zone America/New_York);
}

Util::Log::start_verbose();
Util::Log::start_debug();

eval {
    use SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

my $root = $config->root;

if($root !~ m{^/tmp}) {
    croak();
}

system("mkdir -p $root");
system("mkdir -p $root/etc/sysconfig/network");
system("mkdir -p $root/usr/share/zoneinfo/America");
open(OUT,">$root/usr/share/zoneinfo/America/New_York");
print OUT "test\n";
close(OUT);

eval {
    use Time;
    return 1;
};

ok($@,'') or croak("No point in going any further");

my @files = Time::setup($config);

ok($files[0],"$root/etc/localtime");
ok($files[1],"$root/etc/sysconfig/clock");

ok(scalar(@files));

ok(-e "$root/etc/localtime");

ok(-e "$root/etc/sysconfig/clock");

undef $/;
open(IN,"<$root/etc/sysconfig/clock");
my $var = <IN>;
close(IN);
ok($var,'/GMT="-u"/');
ok($var,'/DEFAULT_TIMEZONE/');

my $rc = system("cmp $root/etc/localtime $root/usr/share/zoneinfo/America/New_York");

ok(!$rc);

system("rm -rf $root");

