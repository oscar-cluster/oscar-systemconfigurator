use Test;
use SystemConfig::Util::Log;
use Data::Dumper;
use Carp;

#
# This test is to
#

BEGIN {
    
    # Set up tests to run
    
    plan tests => 4;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--cfgfile t/cfg/userexit.cfg);
}

SystemConfig::Util::Log::start_verbose();
SystemConfig::Util::Log::start_debug();

eval {
    use SystemConfig::SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    use SystemConfig::UserExit;
    return 1;
};

ok($@,'') or croak("No point in going any further");

if($config->userexit1_cmd) {
    ok(1);
} else {
    ok(0);
}

#
# Okay now we test
#

ok(SystemConfig::UserExit::setup($config),1);

