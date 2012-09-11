use Test;
use Data::Dumper;
use Carp;
use strict;
use vars qw($config);

close(STDERR);

BEGIN {
    
    # Set up 3 tests to run
    
    # Tests here are uber lame, as update-modules doesn't have a chroot flag

    plan tests => 16;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --confighw --cfgfile t/cfg/test.cfg);
}

eval {
    use SCConfig;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    use Hardware;
    return 1;
};

ok($@,'') or croak("No point in going any further");

eval {
    use Modules::ModutilsAliases;
    return 1;
};

ok($@,'') or croak("No point in going any further");


my $root = $config->root();

if(!$root) {
    croak("Running this not chroot is way too dangerous");
}

my $proc = $root . "/proc/bus/pci";

my $dir = $root . "/etc/modutils";

system("mkdir -p $dir");
system("mkdir -p $proc");
system("mkdir -p $root/sbin");

if(!-d $dir) {
    croak("No directory $dir exists");
}

open(OUT,">$dir/aliases");
print OUT "test\n";
close(OUT);
open(OUT,">$root/sbin/update-modules");
print OUT "test\n";
close(OUT);

open(OUT,">$proc/devices");

# The following is a proc dump from one of the lab machines.

print OUT <<END;
0000    808671a2        0       00000008        00000000        00000000 00000000        00000000        00000000        00000000
0018    1014002e        b       00002001        febfe000        00000000 00000000        00000000        00000000        00000000
0020    10140022        0       00000000        00000000        00000000 00000000        00000000        00000000        00000000
0070    10222000        a       00002181        febfdc00        00000000 00000000        00000000        00000000        00000000
0078    53338901        9       f4000000        00000000        00000000 00000000        00000000        00000000        00000000
0098    80867110        0       00000000        00000000        00000000 00000000        00000000        00000000        00000000
0099    80867111        0       00000000        00000000        00000000 00000000        0000ffa1        00000000        00000000
009a    80867112        a       00000000        00000000        00000000 00000000        0000ff01        00000000        00000000
009b    80867113        0       00000000        00000000        00000000 00000000        00000000        00000000        00000000
0110    90048178        b       00005101        fd820000        00000000 00000000        00000000        00000000        00000000
0120    80861229        9       fd821000        00005201        fd800000 00000000        00000000        00000000        00000000
END

close(OUT);

croak() unless (-e "$proc/devices");

# This will blow up, as the update-modules can't run in test, that is ok.
eval {
    Hardware::setup($config);
};

#skip(!$@,1,1,"Can't test without a full chroot");

ok(-e "$dir/aliases");

{
    local($/) = undef;
    open(IN,"<$dir/aliases") or croak("Can't open $dir/aliases");
    my $mcfile = <IN>;
    
    ok($mcfile,'/(^|\n)alias eth0 pcnet32/');
    ok($mcfile,'/\nalias eth1 eepro100/');
    ok($mcfile,'/\nalias scsi_hostadapter ips/');
    ok($mcfile,'/\nalias scsi_hostadapter1 aic7xxx/');
    
    close(IN);
}

########## Second Test ###########

open(OUT,">$proc/devices");

# The following is a proc dump from one of the lab machines.

print OUT <<END;
0000	80861130	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0010	80861132	b	f4000008	fbf80000	00000000	00000000	00000000	00000000	00000000	04000000	00080000	00000000	00000000	00000000	00000000	00000000	
00f0	8086244e	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
00f8	80862440	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
00f9	8086244b	0	00000000	00000000	00000000	00000000	0000fff1	00000000	00000000	00000000	00000000	00000000	00000000	00000010	00000000	00000000	
00fa	80862442	a	00000000	00000000	00000000	00000000	0000fb01	00000000	00000000	00000000	00000000	00000000	00000000	00000020	00000000	00000000	usb-uhci
00fb	80862443	9	00000000	00000000	00000000	00000000	0000fe01	00000000	00000000	00000000	00000000	00000000	00000000	00000010	00000000	00000000	
00fd	80862445	9	0000f001	0000f401	00000000	00000000	00000000	00000000	00000000	00000100	00000040	00000000	00000000	00000000	00000000	00000000	intel810_audio
0140	80861229	b	feaff000	000070c1	feb00000	00000000	00000000	00000000	00000000	00001000	00000040	00100000	00000000	00000000	00000000	00100000	eepro100
0168	121a0005	5	fc000000	f8000008	00007401	00000000	00000000	00000000	00000000	02000000	02000000	00000100	00000000	00000000	00000000	00010000	
0170	1014003e	3	00007801	feafe700	feafe800	00000000	00000000	00000000	00000000	00000100	00000100	00000800	00000000	00000000	00000000	00004000	
END

close(OUT);

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.
eval {
    Hardware::setup($config);
};

ok(-e "$dir/aliases");

{
    local($/) = undef;
    open(IN,"<$dir/aliases") or croak("Can't open $dir/aliases");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\n\# alias eth0 pcnet32/');
    ok($mcfile,'/\nalias eth0 eepro100/');
    ok($mcfile,'/\nalias tr0 olympic/');
    ok($mcfile,'/\nalias eth1 eepro100/');
    ok($mcfile,'/\nalias scsi_hostadapter ips/');
    ok($mcfile,'/\nalias scsi_hostadapter1 aic7xxx/');
    
    close(IN);
}

ok(!system("rm -rf $root"));
