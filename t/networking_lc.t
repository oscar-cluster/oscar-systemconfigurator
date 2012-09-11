use Test;
use Data::Dumper;
use Carp;

BEGIN {
    
    # Set up 24 tests to run
    
    plan tests => 26;
    
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

my $dir = $root . "/etc/sysconfig/network-scripts";

system("mkdir -p $dir");

if(!-d $dir) {
    croak("No directory $dir exists");
}

open(OUT,">$root/etc/sysconfig/network-scripts/ifup");
print OUT "test\n";
close(OUT);

croak() unless (-e "$root/etc/sysconfig/network-scripts/ifup");

# Now we are ready to run tests.

Network::setup($config);

# Does the gateway file exist
ok(-e "$root/etc/sysconfig/network");

@lines = `cat $root/etc/sysconfig/network`;
my $gw = $config->network_gateway();
my $hostname = $config->network_hostname();
my $domain = $config->network_domainname();


# Is there only one line?
my $matches = grep /$gw/, @lines;
ok($matches,1);

# same for host/domain
$matches = grep /$hostname/, @lines;
ok($matches,1);
$matches = grep /$domain/, @lines;
ok($matches,2); #also appears in hostname

# Now we cleanup

local($/) = undef;

ok(-e "$root/etc/sysconfig/network-scripts/ifcfg-dummy0");

open(IN,"<$root/etc/sysconfig/network-scripts/ifcfg-dummy0") or croak("Can't open /etc/sysconfig/network-scripts/ifcfg-dummy0");

my $file = <IN>;
ok($file,'/DEVICE=\"dummy0\"/');
ok($file,'/BOOTPROTO=\"none\"/');
ok($file,'/IPADDR=\"192.168.64.129\"/');
ok($file,'/NETMASK=\"255.255.255.0\"/');
ok($file,'/NETWORK=\"192.168.64.0\"/'); 
ok($file,'/ONBOOT=\"yes\"/'); 

ok(-e "$root/etc/sysconfig/network-scripts/ifcfg-dummy1");

open(IN,"<$root/etc/sysconfig/network-scripts/ifcfg-dummy1") or croak("Can't open /etc/sysconfig/network-scripts/ifcfg-dummy1");

$file = <IN>;

ok($file,'/DEVICE=\"dummy1\"/');
ok($file,'/BOOTPROTO=\"dhcp\"/');
ok($file,'/ONBOOT=\"yes\"/'); 

close(IN);

ok(-e "$root/etc/sysconfig/network-scripts/ifcfg-dummy2");

open(IN,"<$root/etc/sysconfig/network-scripts/ifcfg-dummy2") or croak("Can't open /etc/sysconfig/network-scripts/ifcfg-dummy2");

$file = <IN>;

ok($file,'/DEVICE=\"dummy2\"/');
ok($file,'/BOOTPROTO=\"bootp\"/');
ok($file,'/ONBOOT=\"yes\"/'); 

close(IN);

ok(-e "$root/etc/sysconfig/network-scripts/ifcfg-dummy3");

open(IN,"<$root/etc/sysconfig/network-scripts/ifcfg-dummy3") or croak("Can't open /etc/sysconfig/network-scripts/ifcfg-dummy3");


$file = <IN>;

ok($file,'/DEVICE=\"dummy3\"/');
ok($file,'/BOOTPROTO=\"dhcp\"/');
ok($file,'/ONBOOT=\"yes\"/'); 

close(IN);

ok(system("rm -rf $root"),0);
