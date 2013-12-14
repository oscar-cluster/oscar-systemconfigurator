use Test;
use Data::Dumper;
use Carp;

#
# This test is to
#

BEGIN {
    
    # Set up tests to run
    
    plan tests => 2;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --cfgfile t/cfg/initrd_01.cfg);
}

SystemConfig::Util::Log::start_verbose();
SystemConfig::Util::Log::start_debug();

eval {
  use SystemConfig::SCConfig;
  return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
  use SystemConfig::Initrd;
  return 1;
};

ok($@,'') or croak("No point in going any further");

#
# Okay now we test
#

#SystemConfig::Initrd::setup($config);

