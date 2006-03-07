use Test;
use Data::Dumper;
use Carp;

#
#  This test verifies that /etc/resolv.conf is written (correctly) when both
#  DOMAINNAME and SEARCHDOMAINS are set.  It also tries having
#  NAMESERVER1 through NAMESERVER3 set.
#

BEGIN {
    
    # Set up tests to run
    
    plan tests => 8;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--cfgfile t/cfg/networking_dns_03.cfg);
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

my $dir = $root . "/etc/network";

system("mkdir -p $dir");

open(OUT,">$dir/interfaces");
print OUT "text\n";
close(OUT);

if(!-d $dir) {
  croak("No directory $dir exists");
}

#
# Okay now we test the bare minimal setup, i.e. just
# nameserver1 and domainname set
#

Network::setup($config);

ok(-e "$root/etc/resolv.conf");

local($/) = undef;

open(IN,"<$root/etc/resolv.conf") or croak("Can't open $root/etc/resolv.conf");

my $file = <IN>;

ok($file,'/search alpha.mycluster.big mycluster.big/');
ok($file,'/nameserver 192.168.64.1/');
ok($file,'/nameserver 192.168.64.2/');
ok($file,'/nameserver 192.168.64.3/');

close(IN) or croak("Can't close /etc/resolv.conf");

#
# Now we cleanup
#


ok(system("rm -rf $root"),0);
