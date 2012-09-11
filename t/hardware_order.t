use Test;
use Data::Dumper;
use Carp;
use strict;
use vars qw($config);

BEGIN {
    
    # Set up 20 tests to run
    
    plan tests => 57;
    
    # Here is a trick to make it look like this was called with those args
    # on the command line before SCConfig runs.

    @ARGV = qw(--nocheck --confighw --cfgfile t/cfg/order.cfg);
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

# We loaded the file... now lets setup a fake directory to use

my $root = $config->root();

if(!$root) {
    croak("Running this not chroot is way too dangerous");
}

my $proc = $root . "/proc/bus/pci";

my $dir = $root . "/etc";

my $sbin = $root . "/sbin";

system("mkdir -p $dir");
system("mkdir -p $dir/sysconfig");
system("mkdir -p $proc");
system("mkdir -p $sbin");

if(!-d $dir) {
    croak("No directory $dir exists");
}


### Start SuSE testing

# TEST 1 - x5500 default
reset_test();

setup_x5500();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/conf.modules");
    my $mcfile = <IN>;
    
    ok($mcfile,'/(^|\n)alias eth0 pcnet32/');
    ok($mcfile,'/\nalias eth1 eepro100/');
    ok($mcfile,'/\nalias scsi_hostadapter ips/');
    ok($mcfile,'/\nalias scsi_hostadapter1 aic7xxx/');
    
    close(IN);
}


# TEST 2 - x5500 order change
reset_test();

$config->hardware_order("aic7xxx");

setup_x5500();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/conf.modules");
    my $mcfile = <IN>;
    
    ok($mcfile,'/(^|\n)alias eth0 pcnet32/');
    ok($mcfile,'/\nalias eth1 eepro100/');
    ok($mcfile,'/\nalias scsi_hostadapter aic7xxx/');
    ok($mcfile,'/\nalias scsi_hostadapter1 ips/');
    
    close(IN);
}


# TEST 3 - x5500 order change
reset_test();

$config->hardware_order("eepro100 aic7xxx");

setup_x5500();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/conf.modules");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\nalias eth0 eepro100/');
    ok($mcfile,'/(^|\n)alias eth1 pcnet32/');
    ok($mcfile,'/\nalias scsi_hostadapter aic7xxx/');
    ok($mcfile,'/\nalias scsi_hostadapter1 ips/');
    
    close(IN);
}

# TEST 4 - x5500 order change
reset_test();

$config->hardware_order("eepro100 pcnet32 aic7xxx ips");

setup_x5500();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/conf.modules");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\nalias eth0 eepro100/');
    ok($mcfile,'/(^|\n)alias eth1 pcnet32/');
    ok($mcfile,'/\nalias scsi_hostadapter aic7xxx/');
    ok($mcfile,'/\nalias scsi_hostadapter1 ips/');
    
    close(IN);
}


# TEST 5 - x5500 explicitly specify default
reset_test();

$config->hardware_order("pcnet32 eepro100 ips aic7xxx");

setup_x5500();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/conf.modules");
    my $mcfile = <IN>;
    
    ok($mcfile,'/(^|\n)alias eth0 pcnet32/');
    ok($mcfile,'/\nalias eth1 eepro100/');
    ok($mcfile,'/\nalias scsi_hostadapter ips/');
    ok($mcfile,'/\nalias scsi_hostadapter1 aic7xxx/');
    
    close(IN);
}

# TEST 6 - x345 normal

reset_test();

setup_x345();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/modules.conf");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\nalias eth0 e1000/');
    ok($mcfile,'/\nalias eth1 e1000/');
    ok($mcfile,'/\nalias eth2 e1000/');
    ok($mcfile,'/\nalias scsi_hostadapter ips/');
    ok($mcfile,'/\nalias scsi_hostadapter1 mptscsih/');
    ok($mcfile,'/\nalias scsi_hostadapter2 mptscsih/');

    close(IN);
    
    open(IN,"<$dir/sysconfig/kernel") or croak("Can't open suse kernel file");
    my $kernel = <IN>;
    ok($kernel,'/\nINITRD_MODULES="ips mptscsih mptscsih"/');
    close(IN);
    
}


# TEST 7 - x345 order change

reset_test();

$config->hardware_order("mptscsih");

setup_x345();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/modules.conf");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\nalias eth0 e1000/');
    ok($mcfile,'/\nalias eth1 e1000/');
    ok($mcfile,'/\nalias eth2 e1000/');
    ok($mcfile,'/\nalias scsi_hostadapter mptscsih/');
    ok($mcfile,'/\nalias scsi_hostadapter1 mptscsih/');
    ok($mcfile,'/\nalias scsi_hostadapter2 ips/');
    
    close(IN);
}

# TEST 8 - x345 order change

reset_test();

$config->hardware_order("mptscsih ips");

setup_x345();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/modules.conf");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\nalias eth0 e1000/');
    ok($mcfile,'/\nalias eth1 e1000/');
    ok($mcfile,'/\nalias eth2 e1000/');
    ok($mcfile,'/\nalias scsi_hostadapter mptscsih/');
    ok($mcfile,'/\nalias scsi_hostadapter1 mptscsih/');
    ok($mcfile,'/\nalias scsi_hostadapter2 ips/');
    
    close(IN);
}

# TEST 9 - x345 order change

reset_test();

$config->hardware_order("ips mptscsih");

setup_x345();

croak() unless (-e "$proc/devices");

# Now we are ready to run tests.

Hardware::setup($config);

ok(-e "$dir/modules.conf");

{
    local($/) = undef;
    open(IN,"<$dir/modules.conf") or croak("Can't open $dir/modules.conf");
    my $mcfile = <IN>;
    
    ok($mcfile,'/\nalias eth0 e1000/');
    ok($mcfile,'/\nalias eth1 e1000/');
    ok($mcfile,'/\nalias eth2 e1000/');
    ok($mcfile,'/\nalias scsi_hostadapter ips/');
    ok($mcfile,'/\nalias scsi_hostadapter1 mptscsih/');
    ok($mcfile,'/\nalias scsi_hostadapter2 mptscsih/');
    
    close(IN);
}


ok(system("rm -rf $root"),0);

sub reset_test {
    open(OUT,">$dir/modules.conf");
    close(OUT);
    open(OUT,">$dir/sysconfig/kernel");
    close(OUT);
    open(OUT,">$sbin/SuSEconfig");
    print OUT "#!/bin/sh\n";
    print OUT "echo done";
    close(OUT);
    chmod 0755, "$sbin/SuSEconfig";
    
    unlink "$proc/devices";
}

sub setup_x5500 {
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

}

sub setup_x345 {

# Setup for test x345 

open(OUT,">$proc/devices");

print OUT <<END;
0000	11660014	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0001	11660014	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0002	11660014	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0030	10024752	1a	fd000000	00002401	febff000	00000000	00000000	00000000	00000000	01000000	00000100	00001000	00000000	00000000	00000000	00020000	
0078	11660201	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0079	11660212	0	000001f1	000003f7	00000171	00000377	00000701	00000000	00000000	00000008	00000000	00000008	00000000	00000010	00000000	00000000	
007a	11660220	3	febfe000	00000000	00000000	00000000	00000000	00000000	00000000	00001000	00000000	00000000	00000000	00000000	00000000	00000000	
007b	11660225	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0080	11660101	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0082	11660101	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0088	11660101	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
008a	11660101	0	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	00000000	
0218	80861008	14	fbfe0004	00000000	fbfc0004	00000000	00002501	00000000	00000000	00020000	00000000	00020000	00000000	00000020	00000000	00020000	
0420	101401bd	16	f9ffe008	00000000	00000000	00000000	00000000	00000000	00000000	00002000	00000000	00000000	00000000	00000000	00000000	00080000	ips
0640	80861010	1d	f7fe0004	00000000	00000000	00000000	00002541	00000000	00000000	00020000	00000000	00000000	00000000	00000040	00000000	00000000	e1000
0641	80861010	1e	f7fc0004	00000000	00000000	00000000	00002581	00000000	00000000	00020000	00000000	00000000	00000000	00000040	00000000	00000000	e1000
0838	10000030	1b	00002601	f5ff0004	00000000	f5fe0004	00000000	00000000	00000000	00000100	00010000	00000000	00010000	00000000	00000000	00100000	
0839	10000030	1c	00002701	f5fd0004	00000000	f5fc0004	00000000	00000000	00000000	00000100	00010000	00000000	00010000	00000000	00000000	00100000	
END

close(OUT);

}
