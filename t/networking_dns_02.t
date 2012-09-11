use Test;
use Data::Dumper;
use Carp;


#
#  This test verifies that /etc/resolv.conf is written (correctly) when DOMAINNAME
#  and NAMESERVER1 are both set
#

BEGIN {
    
    # Set up tests to run
    
    plan tests => 4;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SystemConfig::Config runs.

    @ARGV = qw(--cfgfile t/cfg/networking_dns_02.cfg);
}

eval {
  use SCConfig;
  return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
  use Network;
  return 1;
};

ok($@,'') or croak("No point in going any further");

# We loaded the file... now lets setup a fake directory to use

my $root = $config->root();

if(!$root) {
  croak("Running this not chroot is way too dangerous");
}

my $dir = $root . "/etc/";

system("mkdir -p $dir");

if(!-d $dir) {
    croak("No directory $dir exists");
}

Network::setup($config);

ok(! -e "$root/etc/resolv.conf");

#
# Now we cleanup
#

ok(system("rm -rf $root"),0);
