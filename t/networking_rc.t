use Test;
use Data::Dumper;
use Carp;

BEGIN {
    
    # Set up 21 tests to run
    
    plan tests => 21;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --cfgfile t/cfg/test.cfg);
}

eval {
    require SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    require Network;
    return 1;
};

ok($@,'') or croak("No point in going any further");

# We loaded the file... now lets setup a fake directory to use

my $root = $config->root();

if(!$root) {
    croak("Running this not chroot is way too dangerous");
}

my $dir = $root . "/etc";

system("mkdir -p $dir");

if(!-d $dir) {
    croak("No directory $dir exists");
}

open(OUT,">$root/etc/rc.config");
print OUT <<END;
#...
NETCONFIG=""
#...
IPADDR_0=""
IPADDR_1=""
IPADDR_2=""
IPADDR_3=""
#...
NETDEV_0=""
NETDEV_1=""
NETDEV_2=""
NETDEV_3=""
#...
IFCONFIG_0=""
IFCONFIG_1=""
IFCONFIG_2=""
IFCONFIG_3=""
#...

END

close(OUT);

croak() unless (-e "$root/etc/rc.config");

# Now we are ready to run tests.

Network::setup($config);

# Does the gateway file exist
ok(-e "$root/etc/route.conf");

@lines = `cat $root/etc/route.conf`;
my $gw = $config->network_gateway();
my $matches = grep /$gw/, @lines;

# Is there only one line?
ok($matches,1);
ok(scalar(@lines),1);

local($/) = undef;

ok(-e "$root/etc/rc.config");

open(IN,"<$root/etc/rc.config") or croak("Can't open /etc/rc.config");

my $file = <IN>;
ok($file,'/NETCONFIG=\"_0 _1 _2 _3\"/');

ok($file,'/IPADDR_0=\"192.168.64.129\"/');
ok($file,'/IPADDR_1=\"\"/');
ok($file,'/IPADDR_2=\"\"/');
ok($file,'/IPADDR_3=\"\"/');
ok($file,'/NETDEV_0=\"dummy0\"/');
ok($file,'/NETDEV_1=\"dummy1\"/');
ok($file,'/NETDEV_2=\"dummy2\"/');
ok($file,'/NETDEV_3=\"dummy3\"/');
ok($file,'/IFCONFIG_0=\"192.168.64.129 broadcast 192.168.64.255 netmask 255.255.255.0\"/');
ok($file,'/IFCONFIG_1=\"dhcpclient\"/');
ok($file,'/IFCONFIG_2=\"bootp\"/');
ok($file,'/IFCONFIG_3=\"dhcpclient\"/');

#hostname
ok($file,'/FQHOSTNAME=\"test.dual.alpha.mycluster.big\"/');

close(IN);

ok(system("rm -rf $root"),0);
