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

!system("mkdir -p $root/boot") or croak("Couldn't build $root/etc for testing");
!system("mkdir -p $root/etc") or croak("Couldn't build $root/usr/sbin for testing");
!system("mkdir -p $root/sbin") or croak("Couldn't build $root/usr/sbin for testing");

open(OUT,">$root/etc/aboot.conf");
print OUT "test\n";
close(OUT);
chmod 0644, "$root/etc/aboot.conf";

open(OUT,">$root/etc/fstab");
print OUT "/dev/sda3 /boot ext3 defaults,errors=remount-ro 0 1";

close(OUT);
chmod 0644, "$root/etc/fstab";

open(OUT,">$root/boot/bootlx");
print OUT "test\n";
close(OUT);
chmod 0644, "$root/boot/bootlx";

open(OUT,">$root/sbin/swriteboot");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/sbin/swriteboot";

open(OUT,">$root/sbin/abootconf");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/sbin/abootconf";

{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    Boot::install_config($config);
}

open(IN,"<$root/etc/aboot.conf") or croak("Can't open $root/etc/aboot.conf");

local($/) = undef;
my $abootconf = <IN>;
ok($abootconf,'/0:3/vmlinuz initrd=/initrd-2.4.2-2.img/');
ok($abootconf,'/1:3/vmlinuz single initrd=/initrd-2.4.2-2.img/');
ok(!system("rm -rf $root"));
