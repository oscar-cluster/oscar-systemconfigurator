use Test;
use Data::Dumper;
use Carp;
use strict;
use vars qw($config);

BEGIN {
    
    # Set up 20 tests to run
    
    plan tests => 13;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --norunboot --cfgfile t/cfg/boot.cfg);
}

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

!system("mkdir -p $root/etc") or croak("Can't generate $root/etc for test");
!system("mkdir -p $root/boot") or croak("Can't generate $root/etc for test");
!system("mkdir -p $root/proc") or croak("Can't generate $root/proc for test");

open(OUT,">$root/boot/yaboot");
print OUT "Your Moma\n";
close(OUT);

open(OUT,">$root/proc/cpuinfo") or croak("Can't make fake proc/cpuinfo\n");
print OUT "machine: chrp\n";
close(OUT);

{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    Boot::install_config($config);
}

open(IN,"<$root/etc/yaboot.conf") or croak("No yaboot.conf created!\n");

local($/) = undef;
my $yabootconf = <IN>;
close(IN);

ok($yabootconf,'/root=/dev/sda5/');
ok($yabootconf,'/timeout=50/');
ok($yabootconf,'/default=linux-multi/');
ok($yabootconf,'/image=/tmp/sctests/boot/vmlinuz/');
ok($yabootconf,'/label=linux-multi/');
ok($yabootconf,'/initrd=/tmp/sctests/boot/initrd-2.4.2-2.img/');
ok($yabootconf,'/image=/tmp/sctests/boot/vmlinuz/');
ok($yabootconf,'/label=linux-single/');
ok($yabootconf,'/append="single"/');
ok($yabootconf,'/root=/dev/sda5/');
ok($yabootconf,'/initrd=/tmp/sctests/boot/initrd-2.4.2-2.img/');

system("rm -rf $root");















































