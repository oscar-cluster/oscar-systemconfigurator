use Test;
use Carp;
use Data::Dumper;
use strict;
use vars qw($PERL $config @ARGV);

BEGIN {
    plan tests => 15;
    @ARGV = qw(--nocheck --cfgfile t/cfg/test.cfg);
}

$PERL = "perl -w -Iblib/lib";

eval {
    use SCConfig;
    return 1;
};

# We need this to run the executable

ok($@,'') or croak("No point in going any further");

ok(!system("$PERL blib/script/systemconfigurator --nocheck --cfgfile t/cfg/test.cfg --confignet > /dev/null"));

# Here is setup for generating linuxconf networking

my $root = $config->root();

if(!$root) {
    croak("Running this not chroot is way too dangerous");
}

my $dir = $root . "/etc/sysconfig/network-scripts";

system("mkdir -p $dir");

if(!-d $dir) {
    croak("No directory $dir exists");
}

open(OUT,">$root/etc/sysconfig/network-scripts/ifup");
print OUT "test\n";
close(OUT);

croak() unless (-e "$root/etc/sysconfig/network-scripts/ifup");

# Setup is done now

ok(!system("$PERL blib/script/systemconfigurator --nocheck --confignet --confighw --cfgfile t/cfg/test.cfg --excludesto $root/excludes.log > /dev/null"));

local $/ = undef;

open(IN,"<$root/excludes.log") or croak("Can't open $root/excludes.log for reading");

my $contents = <IN>;


ok($contents,"/\/etc\/systemconfig\/systemconfig.conf/");
ok($contents,"/$root\/etc\/sysconfig\/network/");
ok($contents,"/$root\/etc\/sysconfig\/network-scripts\/ifcfg-dummy0/");
ok($contents,"/$root\/etc\/sysconfig\/network-scripts\/ifcfg-dummy1/");
ok($contents,"/$root\/etc\/sysconfig\/network-scripts\/ifcfg-dummy2/");
ok($contents,"/$root\/etc\/sysconfig\/network-scripts\/ifcfg-dummy3/");

($contents !~ /$root\/etc\/rc\.config/) ? ok(1) : ok(0);
($contents !~ /$root\/etc\/network\/interfaces/) ? ok(1) : ok(0);
($contents !~ /$root\/etc\/init\.d\/network/) ? ok(1) : ok(0);
($contents !~ /$root\/etc\/route\.conf/) ? ok(1) : ok(0);

# Time to cleanup

ok(!system("rm -rf $root"));

# Now just for fun... does the exit code on the --help look like what we expect

ok(system("$PERL blib/script/systemconfigurator --help > /dev/null"),256);
