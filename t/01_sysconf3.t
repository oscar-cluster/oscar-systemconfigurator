# This is a test of the config file parsing.  There are certain options which should be there
# and others which should not.

use Test;
use Data::Dumper;

BEGIN {plan tests => 9;
       @ARGV = qw(--configsi --confighw --cfgfile t/cfg/options1.cfg);
}

eval {
    use SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

# first, possitive tests
ok($config->confignet);
ok($config->confighw);
ok($config->runboot);
ok(!$config->configboot);
ok(!$config->configrd);
ok($config->configtime);
ok($config->configkeyboard);
ok($config->configuserexit);
