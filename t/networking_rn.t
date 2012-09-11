use Test;
use Data::Dumper;
use Carp;

BEGIN {
    
    # Set up 10 tests to run
    
    plan tests => 10;
    
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

my $dir = $root . "/etc/init.d";

system("mkdir -p $dir");

if(!-d $dir) { 
    croak("No directory $dir exists");
}

open(OUT,">$root/etc/init.d/network");
print OUT <<END;
#! /bin/sh
# 

ifconfig lo 127.0.0.1
route add -net 127.0.0.0

ifconfig eth0 \${IPADDR} netmask \${NETMASK} broadcast \${BROADCAST}

END

close(OUT);

croak() unless (-e "$root/etc/init.d/network");

# Now we are ready to run tests.

Network::setup($config);

# Does the gateway file exist
ok(-e "$root/etc/init.d/network");

local($/) = undef;

open(IN,"<$root/etc/init.d/network") or croak("Can't open $root/etc/init.d/network");

my $file = <IN>;
ok($file,'/ifconfig lo 127.0.0.1/');
ok($file,'/route add -net 127.0.0.0 netmask 255.0.0.0 lo/');
ok($file,'/ifconfig dummy0 192.168.64.129 netmask 255.255.255.0 broadcast 192.168.64.255/');
ok($file,'/route add -net 192.168.64.0/');
ok($file,'/route add default gw 192.168.64.1 metric 1/');

close(IN);

#okay, did we do the hostname stuff right?

open(IN,"<$root/etc/hostname") or croak("Can't open /etc/hostname");

$file = <IN>;
chomp $file;
ok($file,'/^test$/');

ok(system("rm -rf $root"),0);
