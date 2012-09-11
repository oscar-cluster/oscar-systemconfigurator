use Test;
use Data::Dumper;
use Carp;
use strict;
use vars qw($config);
use Util::Log;

BEGIN {
    
    # Set up 20 tests to run
    
    plan tests => 15;
    
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

open(OUT,">$root/sbin/lilo");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/sbin/lilo";

{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    Boot::install_config($config);
}

open(IN,"<$root/etc/lilo.conf") or croak("Can't open $root/etc/lilo.conf");

local($/) = undef;
my $liloconf = <IN>;
ok($liloconf,'/boot=/dev/sda/');
ok($liloconf,'/root=/dev/sda5/');
ok($liloconf,'/timeout=50/');
ok($liloconf,'/vga=normal/');
ok($liloconf,'/default=linux-multi/');
ok($liloconf,'/image=/tmp/sctests/boot/vmlinuz/');
ok($liloconf,'/label=linux-multi/');
ok($liloconf,'/initrd=/tmp/sctests/boot/initrd-2.4.2-2.img/');
ok($liloconf,'/image=/tmp/sctests/boot/vmlinuz/');
ok($liloconf,'/label=linux-single/');
ok($liloconf,'/append="single"/');
ok($liloconf,'/root=/dev/sda5/');
ok($liloconf,'/initrd=/tmp/sctests/boot/initrd-2.4.2-2.img/');

system("rm -rf $root");















































