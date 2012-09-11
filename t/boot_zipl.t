use Test;
use Data::Dumper;
use Carp;
use strict;
use vars qw($config);
use Util::Log;

BEGIN {
    
    # Set up 20 tests to run
    
    plan tests => 14;
    
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
!system("mkdir -p $root/boot") or croak("Couldn't build $root/boot for testing");

open(OUT,">$root/sbin/zipl");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/sbin/zipl";

{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    Boot::install_config($config);
}

open(IN,"<$root/etc/zipl.conf") or croak("Can't open $root/etc/zipl.conf");

local($/) = undef;
my $ziplconf = <IN>;
ok($ziplconf,'/defaultboot/');
ok($ziplconf,'/default=linux-multi/');
ok($ziplconf,'/linux-multi/');
ok($ziplconf,'/target=/tmp/sctests/boot/');
ok($ziplconf,'/image=/tmp/sctests/boot/vmlinuz/');
ok($ziplconf,'/parmfile=/tmp/sctests/boot/parmfile-linux-multi/');
ok($ziplconf,'/ramdisk=/tmp/sctests/boot/initrd-2.4.2-2.img/');
ok($ziplconf,'/linux-single/');
ok($ziplconf,'/target=/tmp/sctests/boot/');
ok($ziplconf,'/image=/tmp/sctests/boot/vmlinuz/');
ok($ziplconf,'/parmfile=/tmp/sctests/boot/parmfile-linux-single/');
ok($ziplconf,'/ramdisk=/tmp/sctests/boot/initrd-2.4.2-2.img/');

system("rm -rf $root");















































