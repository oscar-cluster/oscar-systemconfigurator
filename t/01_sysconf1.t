# This is a test of the config file parsing.  There are certain options which should be there
# and others which should not.

use Test;
use Data::Dumper;

BEGIN {plan tests => 19;
       @ARGV = qw(--quiet --nocheck --maxkernel=20 --cfgfile t/cfg/options.cfg);
}

eval {
    use SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

# first, possitive tests

ok($config->maxkernel(), 20);
ok($config->root(),"/tmp/sctests");
ok($config->interface0_type(),"static");
ok($config->interface1_device(),"dummy1");
ok($config->kernel0_path(),"/boot/vmlinuz");
ok($config->kernel1_append(),"single");
ok($config->boot_vga(),"test");
ok($config->boot_extras(),"go team");

my %vars = $config->varlist("^interface.*type");
ok(scalar(keys %vars),4); 

%vars = $config->varlist("^kernel.*path");
ok(scalar(keys %vars),20); 

ok($config->kernel12_path(),'dummy12');

# now negative tests
ok(!$config->kernel00_path());
ok(!$config->kernel01_path());

ok(!$config->kernel3_badoption());
ok(!$config->kernel103_path());

# now defined tests

ok(defined($config->kernel5_path()));
ok(defined($config->kernel15_path()));
ok(!defined($config->kernel149_path()));
