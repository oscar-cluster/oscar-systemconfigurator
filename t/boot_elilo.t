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
!system("mkdir -p $root/usr/sbin") or croak("Couldn't build $root/usr/sbin for testing");

open(OUT,">$root/etc/elilo.conf");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/etc/elilo.conf";

open(OUT,">$root/usr/sbin/elilo");
print OUT "test\n";
close(OUT);
chmod 0755, "$root/usr/sbin/elilo";

{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    Boot::install_config($config);
}

open(IN,"<$root/etc/elilo.conf") or croak("Can't open $root/boot/efi/elilo.conf");

local($/) = undef;
my $eliloconf = <IN>;
ok($eliloconf,'/root=/dev/sda5/');
ok($eliloconf,'/delay=50/');
ok($eliloconf,'/default=linux-multi/');
# The number of times this string is evaled is really annoying
# The following condense to checking for \boot\vmlinuz
ok($eliloconf,'/image=/boot/vmlinuz/');
ok($eliloconf,'/label=linux-multi/');
ok($eliloconf,'/initrd=/tmp/sctests/boot/initrd-2.4.2-2.img/');
ok($eliloconf,'/image=/boot/vmlinuz/');
ok($eliloconf,'/label=linux-single/');
ok($eliloconf,'/append="single"/');
ok($eliloconf,'/root=/dev/sda5/');
ok($eliloconf,'/initrd=/tmp/sctests/boot/initrd-2.4.2-2.img/');

ok(!system("rm -rf $root"));
