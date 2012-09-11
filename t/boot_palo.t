use Test;
use Data::Dumper;
use Carp;
use strict;
use vars qw($config);
use Util::Log;

BEGIN {
    
    # Set up 20 tests to run
    
    plan tests => 5;

    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --norunboot --cfgfile t/cfg/boot.cfg);
}

#Util::Log::start_verbose();
#Util::Log::start_debug();

eval {
    use SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    use Boot;
    return 1;
};

ok($@,'') or croak("No point in going any further");

# We loaded the file... now lets setup a fake directory to use

my $root = $config->root();

if(!$root) {
    croak("Running this not chroot is way too dangerous");
}

!system("mkdir -p $root/etc") or croak("Couldn't build $root/etc for testing");
!system("mkdir -p $root/sbin") or croak("Couldn't build $root/sbin for testing");
!system("cp t/boot/fstab $root/etc/fstab") or croak("Cannot write into $root/etc");

open(OUT,">$root/sbin/palo");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/sbin/palo";
{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    Boot::install_config($config);
}

open(IN,"<$root/etc/palo.conf") or croak("Can't open $root/etc/palo.conf");

local($/) = undef;
my $paloconf = <IN>;
ok($paloconf,'/--bootloader=/boot/iplboot/');
ok($paloconf,'/--init-partitioned=/dev/sda/');
ok($paloconf,'/--commandline=1/boot/vmlinuz/');

system("rm -rf $root");
