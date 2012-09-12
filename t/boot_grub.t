use Test;
use Data::Dumper;
use Util::Cmd qw(:all);
use Util::Log qw(:all);
use File::Copy;
use Carp;
use strict;
use vars qw($config);

BEGIN {
    
    # Set up 20 tests to run
    
    plan tests => 10;
    
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

!system("mkdir -p $root/boot/grub") or croak("Cannot create $root/boot/grub");
!system("mkdir -p $root/etc") or croak("Cannot create $root/etc");
!system("mkdir -p $root/proc") or croak("Cannot create $root/proc");
!system("mkdir -p $root/usr/sbin") or croak("Couldn't build $root/usr/sbin for testing");  
!system("mkdir -p $root/sbin") or croak("Couldn't build $root/sbin for testing");  

my $skip;

chomp(my $grub=`which grub`);
if (!$grub) {
    croak("Could not locate grub! Is your PATH including /usr/sbin?");
}

copy("/proc/partitions","$root/proc/partitions") or ($skip = 1);
copy("/etc/fstab","$root/etc/fstab") or ($skip = 1);
copy(which('grub'),"$root/usr/sbin/grub") or ($skip = 1);
copy(which('e2label'),"$root/usr/sbin/e2label") or ($skip = 1);
copy(which('cat'),"$root/bin/cat") or ($skip = 1);
copy(which('blkid'),"$root/sbin/blkid") or ($skip = 1);
copy(which('grub-install'),"$root/usr/sbin/grub-install") or ($skip = 1);
system("chmod a+x $root/usr/sbin/*");
system("chmod a+x $root/sbin/*");

open(OUT, ">$root/boot/vmlinuz");
print OUT "test\n";
close(OUT);
chmod 0644, "$root/boot/vmlinuz";

open(OUT, ">$root/boot/initrd-2.4.2-2.img");
print OUT "test\n";
close(OUT);
chmod 0644, "$root/boot/initrd-2.4.2-2.img";

{
    # This takes care of running which in the chroot land
    local %ENV = %ENV;
    $ENV{PATH} = '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:' . $ENV{PATH};
    $ENV{PATH} = join ':', (map {"$root$_"} split(/:/,$ENV{PATH}));
    eval {
        Boot::install_config($config);
    };
}
	
open(IN,"<$root/boot/grub/menu.lst") or croak("Can't open $root/boot/grub/menu.lst");
	
local($/) = undef;   
my $grubconf = <IN>;    
skip($skip,$grubconf,'/timeout 5/');
skip($skip,$grubconf,'/default 0/');    
skip($skip,$grubconf,'/title linux-multi/');
skip($skip,$grubconf,'/kernel \(hd\d+,\d+\)/(boot/)?vmlinuz ro root=/dev/sda5/');
skip($skip,$grubconf,'/initrd \(hd\d+,\d+\)/(boot/)?initrd-2.4.2-2.img/');
skip($skip,$grubconf,'/title linux-single/');
skip($skip,$grubconf,'/kernel \(hd\d+,\d+\)/(boot/)?vmlinuz ro root=/dev/sda5 single/');
skip($skip,$grubconf,'/initrd \(hd\d+,\d+\)/(boot/)?initrd-2.4.2-2.img/');

close(IN);

system("rm -rf $root");

