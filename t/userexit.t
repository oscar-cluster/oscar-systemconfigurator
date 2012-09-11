use Test;
use Util::Log;
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

Util::Log::start_verbose();
Util::Log::start_debug();

eval {
    use SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    use UserExit;
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

ok(UserExit::setup($config),1);

