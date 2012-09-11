package Hardware::PCI::Table;

#   $Id: Table.pm 664 2007-01-15 21:40:36Z arighi $

#   Copyright (c) 2001-2005 International Business Machines

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#   Sean Dague <japh@us.ibm.com>

# This module is generated automagically by pcitable2pm.pl from the pcitable file
# which is in the kudzu rpm for Fedora and the pcitable file from Mandrake 10.1
# CVS tree.  (When in conflict, the Red Hat devices were prefered) 

use strict;
use Carp;
use Util::Log qw(:all);
use vars qw($PCI $VERSION @ISA @EXPORT_OK @EXPORT %EXPORT_TAGS);
use base qw(Exporter);

%EXPORT_TAGS = ( 
                'all' => [
                          qw(pci_entry pci_module pci_type pci_vendor pci_product)
                         ],
               );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

$VERSION = sprintf("%d", q$Revision: 664 $ =~ /(\d+)/);

sub _load_overrides {
    my ($file) = @_;
    if(! -e $file) {
        return 1;
    }
    open(IN,$file) or croak("Couldn't load overrides file $file");
    while(<IN>) {
        s/^\s+//;
        my ($vend, $id, $type, $module, $vendor, $product) = split(/\s+/,$_);
        if($vend and $id and $type and $module) {
             verbose("Added $type:$module entry for '$vend $id'");
             $PCI->{$vend}->{$id} = {
                                     type => $type,
                                     module => $module,
                                     vendor => $vendor,
                                     product => $product,
                                    };
        }
    }
    close(IN);
    return 1;
}

sub _device_lookup {
    my ($vend, $dev) = @_;
    my %hash;
    if($vend =~ /^(\w{4})(\w{4})$/) {
        return %{$PCI->{$1}->{$2}} if $PCI->{$1}->{$2};
    } elsif (length($vend) == length($dev) and length($dev) == 4) {
        return %{$PCI->{$vend}->{$dev}} if $PCI->{$vend}->{$dev};
    } else {
        return %hash;
    }
    return %hash;
}

sub pci_entry {
    my %hash = _device_lookup(@_);
    return \%hash;
}

sub pci_vendor {
    my %hash = _device_lookup(@_);
    return $hash{vendor};
}

sub pci_module {
    my %hash = _device_lookup(@_);
    return $hash{module};
}

sub pci_type {
    my %hash = _device_lookup(@_);
    return $hash{type};
}

sub pci_product {
    my %hash = _device_lookup(@_);
    return $hash{product};
}

$PCI = {

'018a' => {
	'0106' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'LevelOne',
		'product' => 'FPC-0106TX misprogrammed [RTL81xx]',
		},
	},
'021b' => {
	'8139' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Compaq Computer Corp.',
		'product' => 'HNE-300 (RealTek RTL8139c) [iPaq Networking]',
		},
	},
'02ac' => {
	'1012' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'SpeedStream',
		'product' => '1012 PCMCIA 10/100 Ethernet Card [RTL81xx]',
		},
	},
'0e11' => {
	'0046' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 64xx',
		},
	'0508' => {
		'type' => 'tokenring',
		'module' => 'tmspci',
		'vendor' => 'Compaq',
		'product' => 'Netelligent 4/16 Token Ring',
		},
	'4030' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'SMART-2/P',
		},
	'4031' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'SMART-2SL',
		},
	'4032' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 3200',
		},
	'4033' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 3100ES',
		},
	'4034' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 221',
		},
	'4040' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Integrated Array',
		},
	'4048' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Compaq Raid LC2',
		},
	'4050' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 4200',
		},
	'4051' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 4250ES',
		},
	'4058' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 431',
		},
	'4070' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 5300',
		},
	'4080' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 5i',
		},
	'4082' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 532',
		},
	'4083' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 5312',
		},
	'4091' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 6i',
		},
	'409a' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 641',
		},
	'409b' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 642',
		},
	'409c' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 6400',
		},
	'409d' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 6400 EM',
		},
	'ae10' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'Compaq',
		'product' => 'Smart-2/P RAID Controller',
		},
	'ae32' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Netelligent 10/100',
		},
	'ae34' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Netelligent 10',
		},
	'ae35' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Integrated NetFlex-3/P',
		},
	'ae40' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Netelligent 10/100 Dual',
		},
	'ae43' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'ProLiant Integrated Netelligent 10/100',
		},
	'ae6c' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Northstar',
		},
	'b011' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Integrated Netelligent 10/100',
		},
	'b012' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Netelligent 10 T/2',
		},
	'b030' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'Netelligent WS 5100',
		},
	'b060' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'Compaq',
		'product' => 'Smart Array 5300 Controller',
		},
	'b178' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => 'CISSB',
		'product' => 'Smart Array 5i/532 cards',
		},
	'f130' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'NetFlex-3/P ThunderLAN 1.0',
		},
	'f150' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Compaq',
		'product' => 'NetFlex-3/P ThunderLAN 2.3',
		},
	},
'1000' => {
	'0030' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => '53c1030',
		},
	'0032' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'LSI Logic / Symbios Logic',
		'product' => '53c1035 PCI-X Fusion-MPT Dual Ultra320 SCSI',
		},
	'0040' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'LSI Logic / Symbios Logic',
		'product' => '53c1035 PCI-X Fusion-MPT Dual Ultra320 SCSI',
		},
	'0407' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'LSI Logic',
		'product' => 'PowerEdge RAID Controller 4/QC',
		},
	'0621' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC909',
		},
	'0622' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC929',
		},
	'0623' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC929 LAN',
		},
	'0624' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC919',
		},
	'0625' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC919 LAN',
		},
	'0626' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC929X',
		},
	'0627' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC929X_LAN',
		},
	'0628' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC919X',
		},
	'0629' => {
		'type' => 'scsi',
		'module' => 'mptscsih',
		'vendor' => 'Symbios',
		'product' => 'FC919X_LAN',
		},
	'0701' => {
		'type' => 'ethernet',
		'module' => 'yellowfin',
		'vendor' => 'Symbios',
		'product' => '83C885 gigabit ethernet',
		},
	'0702' => {
		'type' => 'ethernet',
		'module' => 'yellowfin',
		'vendor' => 'Symbios',
		'product' => 'Yellowfin G-NIC gigabit ethernet',
		},
	'1960' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'LSI Logic',
		'product' => 'PowerEdge RAID Controller 3/QC',
		},
	},
'100b' => {
	'0020' => {
		'type' => 'ethernet',
		'module' => 'natsemi',
		'vendor' => 'National Semi',
		'product' => 'DP83810 10/100 Ethernet',
		},
	'0022' => {
		'type' => 'ethernet',
		'module' => 'ns83820',
		'vendor' => 'National Semi',
		'product' => 'DP83820 10/100/1000 Ethernet',
		},
	},
'1011' => {
	'0001' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'DEC',
		'product' => 'DECchip 21050',
		},
	'0009' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'DEC',
		'product' => 'DECchip 21140 [FasterNet]',
		},
	'000f' => {
		'type' => 'ethernet',
		'module' => 'defxx',
		'vendor' => 'DEC',
		'product' => 'DEFPA',
		},
	'0019' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'DEC',
		'product' => 'DECchip 21142/43',
		},
	'001a' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Farallon',
		'product' => 'PN9000SX',
		},
	'0021' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'DEC',
		'product' => 'DECchip 21052',
		},
	'0022' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'DEC',
		'product' => 'DECchip 21150',
		},
	'0046' => {
		'type' => 'scsi',
		'module' => 'cpqarray',
		'vendor' => 'DEC',
		'product' => 'DECchip 21554 [Compaq Smart Array Controller]',
		},
	'1065' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'DEC',
		'product' => 'RAID Controller',
		},
	},
'1014' => {
	'0018' => {
		'type' => 'tokenring',
		'module' => 'lanstreamer',
		'vendor' => 'IBM',
		'product' => 'TR Auto LANstreamer',
		},
	'002e' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID controller',
		},
	'003e' => {
		'type' => 'tokenring',
		'module' => 'olympic',
		'vendor' => 'IBM',
		'product' => '16/4 Token ring UTP/STP controller',
		},
	'005c' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'IBM',
		'product' => 'i82557B 10/100 PCI Ethernet Adapter',
		},
	'0180' => {
		'type' => 'scsi',
		'module' => 'ipr',
		'vendor' => 'IBM',
		'product' => 'Snipe chipset SCSI controller',
		},
	'01bd' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID controller',
		},
	'01be' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID-4M',
		},
	'01bf' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID-4L',
		},
	'0208' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID-4Mx',
		},
	'020e' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID-4Lx',
		},
	'022e' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'IBM',
		'product' => 'ServeRAID-4H',
		},
	},
'101a' => {
	'0005' => {
		'type' => 'ethernet',
		'module' => 'hp100',
		'vendor' => 'AT&T GIS (NCR)',
		'product' => '100VG ethernet',
		},
	},
'101e' => {
	'1960' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'AMI',
		'product' => 'PowerEdge RAID Controller 3/QC',
		},
	'9010' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'AMI',
		'product' => 'MegaRAID',
		},
	'9060' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'AMI',
		'product' => 'MegaRAID 434 Ultra GT RAID Controller',
		},
	'9063' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'AMI',
		'product' => 'MegaRAC',
		},
	},
'1022' => {
	'2000' => {
		'type' => 'ethernet',
		'module' => 'pcnet32',
		'vendor' => 'Advanced Micro Devices',
		'product' => '79c970 [PCnet LANCE]',
		},
	'2001' => {
		'type' => 'ethernet',
		'module' => 'pcnet32',
		'vendor' => 'Advanced Micro Devices',
		'product' => '79c978 [HomePNA]',
		},
	'2020' => {
		'type' => 'scsi',
		'module' => 'tmscsim',
		'vendor' => 'Advanced Micro Devices',
		'product' => '53c974 [PCscsi]',
		},
	'7462' => {
		'type' => 'ethernet',
		'module' => 'amd8111e',
		'vendor' => 'Advanced Micro Devices',
		'product' => 'AMD-8111 Ethernet',
		},
	},
'1028' => {
	'0001' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 2/Si',
		},
	'0002' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Di',
		},
	'0003' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Si',
		},
	'0004' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Si',
		},
	'0005' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Di',
		},
	'0006' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Di',
		},
	'0008' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Di',
		},
	'000a' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge Expandable RAID Controller 3/Di',
		},
	'000e' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge RAID Controller',
		},
	'000f' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'Dell Computer Corp.',
		'product' => 'PowerEdge RAID Controller 4/DI',
		},
	},
'102f' => {
	'0030' => {
		'type' => 'ethernet',
		'module' => 'tc35815',
		'vendor' => 'Toshiba America',
		'product' => 'NIC TC35815CF',
		},
	},
'1036' => {
	'0000' => {
		'type' => 'scsi',
		'module' => 'fdomain',
		'vendor' => 'Future Domain',
		'product' => 'TMC-18C30 [36C70]',
		},
	},
'1039' => {
	'0180' => {
		'type' => 'scsi',
		'module' => 'sata_sis',
		'vendor' => 'Silicon Integrated Systems [SiS]',
		'product' => 'RAID bus controller 180 SATA/PATA  [SiS]',
		},
	'0181' => {
		'type' => 'scsi',
		'module' => 'sata_sis',
		'vendor' => 'Silicon Integrated Systems [SiS]',
		'product' => '',
		},
	'0900' => {
		'type' => 'ethernet',
		'module' => 'sis900',
		'vendor' => 'Silicon Integrated Systems [SiS]',
		'product' => 'SiS900 10/100 Ethernet',
		},
	'7016' => {
		'type' => 'ethernet',
		'module' => 'sis900',
		'vendor' => 'Silicon Integrated Systems [SiS]',
		'product' => 'SiS900 10/100 Ethernet',
		},
	},
'103c' => {
	'1030' => {
		'type' => 'ethernet',
		'module' => 'hp100',
		'vendor' => 'HP',
		'product' => 'J2585A',
		},
	'1031' => {
		'type' => 'ethernet',
		'module' => 'hp100',
		'vendor' => 'HP',
		'product' => 'J2585B',
		},
	'1040' => {
		'type' => 'ethernet',
		'module' => 'hp100',
		'vendor' => 'HP',
		'product' => 'J2973A DeskDirect 10BaseT NIC',
		},
	'1042' => {
		'type' => 'ethernet',
		'module' => 'hp100',
		'vendor' => 'HP',
		'product' => 'J2970A DeskDirect 10BaseT/2 NIC',
		},
	'10c2' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'HP',
		'product' => 'NetRAID-4M',
		},
	'3210' => {
		'type' => 'scsi',
		'module' => 'cciss',
		'vendor' => '',
		'product' => '',
		},
	},
'1044' => {
	'a400' => {
		'type' => 'scsi',
		'module' => 'eata',
		'vendor' => 'Distributed Processing Tech',
		'product' => 'SmartCache/Raid I-IV Controller',
		},
	'a501' => {
		'type' => 'scsi',
		'module' => 'dpt_i2o',
		'vendor' => 'Distributed Processing Tech',
		'product' => 'SmartRAID V Controller',
		},
	'a511' => {
		'type' => 'scsi',
		'module' => 'dpt_i2o',
		'vendor' => 'Distributed Processing Tech',
		'product' => 'Raptor SmartRAID Controller',
		},
	},
'104a' => {
	'0981' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'ST Microelectronics',
		'product' => ' Ethernet Controller',
		},
	'2774' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'ST Microelectronics',
		'product' => 'STE10/100A PCI 10/100 Ethernet Controller',
		},
	},
'104b' => {
	'0140' => {
		'type' => 'scsi',
		'module' => 'BusLogic',
		'vendor' => 'BusLogic',
		'product' => 'BT-946C (old) [multimaster 01]',
		},
	'1040' => {
		'type' => 'scsi',
		'module' => 'BusLogic',
		'vendor' => 'BusLogic',
		'product' => 'BT-946C (BA80C30) [MultiMaster 10]',
		},
	'8130' => {
		'type' => 'scsi',
		'module' => 'BusLogic',
		'vendor' => 'BusLogic',
		'product' => 'Flashpoint LT',
		},
	},
'1050' => {
	'0000' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Winbond Electronics Corp',
		'product' => 'NE2000',
		},
	'0940' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Winbond Electronics Corp',
		'product' => 'W89C940',
		},
	'5a5a' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Winbond Electronics Corp',
		'product' => 'W89C940F',
		},
	},
'105a' => {
	'3318' => {
		'type' => 'scsi',
		'module' => 'sata_promise',
		'vendor' => 'Promise Technology',
		'product' => 'PDC20318 FastTrak SATA150 TX4 Controller',
		},
	'3319' => {
		'type' => 'scsi',
		'module' => 'sata_promise',
		'vendor' => 'Promise Technology',
		'product' => 'PDC20319 FastTrak SATA150 TX4 Controller',
		},
	'3371' => {
		'type' => 'scsi',
		'module' => 'sata_promise',
		'vendor' => 'Promise Technology',
		'product' => 'PDC20371 FastTrak SATA150 TX2plus Controller',
		},
	'3373' => {
		'type' => 'scsi',
		'module' => 'sata_promise',
		'vendor' => 'Promise Technology',
		'product' => 'PDC20376 FastTrak 378 Controller',
		},
	'3375' => {
		'type' => 'scsi',
		'module' => 'sata_promise',
		'vendor' => 'Promise Technology',
		'product' => 'PDC20375 FastTrak SATA150 TX2plus Controller',
		},
	'3376' => {
		'type' => 'scsi',
		'module' => 'sata_promise',
		'vendor' => 'Promise Technology',
		'product' => 'PDC20376 FastTrak 376 Controller',
		},
	'6622' => {
		'type' => 'scsi',
		'module' => 'sata_sx4',
		'vendor' => 'Promise Technology',
		'product' => 'PDC2037X FastTrak Controller',
		},
	'8000' => {
		'type' => 'scsi',
		'module' => 'sx8',
		'vendor' => 'Promise Technology, Inc.',
		'product' => '',
		},
	'8002' => {
		'type' => 'scsi',
		'module' => 'sx8',
		'vendor' => 'Promise Technology, Inc.',
		'product' => '',
		},
	},
'1069' => {
	'0001' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'DAC960P',
		},
	'0002' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'DAC960PD',
		},
	'0010' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'DAC960PX',
		},
	'0020' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'DAC960 V5',
		},
	'0050' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'Raid Adapter (DAC960)',
		},
	'b166' => {
		'type' => 'scsi',
		'module' => 'ipr',
		'vendor' => 'Mylex Corp.',
		'product' => 'Gemstone chipset SCSI controller',
		},
	'ba55' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'eXtremeRAID support Device',
		},
	'ba56' => {
		'type' => 'scsi',
		'module' => 'DAC960',
		'vendor' => 'Mylex Corp.',
		'product' => 'eXtremeRAID 2000/3000 support Device',
		},
	},
'106b' => {
	'0021' => {
		'type' => 'ethernet',
		'module' => 'sungem',
		'vendor' => 'Apple Computer Inc.',
		'product' => 'UniNorth GMAC Ethernet controller',
		},
	'0024' => {
		'type' => 'ethernet',
		'module' => 'sungem',
		'vendor' => 'Apple Computer Inc.',
		'product' => 'GMAC Ethernet controller',
		},
	'0032' => {
		'type' => 'ethernet',
		'module' => 'sungem',
		'vendor' => 'Apple Computer Inc.',
		'product' => 'UniNorth 2 GMAC (Sun GEM)',
		},
	'004c' => {
		'type' => 'ethernet',
		'module' => 'sungem',
		'vendor' => 'Apple Computer Inc.',
		'product' => '',
		},
	'1645' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Apple Computer Inc.',
		'product' => 'Tigon3 Gigabit Ethernet NIC (BCM5701)',
		},
	},
'1077' => {
	'1016' => {
		'type' => 'scsi',
		'module' => 'qla1280',
		'vendor' => 'Q Logic',
		'product' => 'QLA10160',
		},
	'1020' => {
		'type' => 'scsi',
		'module' => 'qlogicisp',
		'vendor' => 'Q Logic',
		'product' => 'ISP1020',
		},
	'1022' => {
		'type' => 'scsi',
		'module' => 'qlogicisp',
		'vendor' => 'Q Logic',
		'product' => 'ISP1022',
		},
	'1080' => {
		'type' => 'scsi',
		'module' => 'qla1280',
		'vendor' => 'Q Logic',
		'product' => 'QLA1080',
		},
	'1216' => {
		'type' => 'scsi',
		'module' => 'qla1280',
		'vendor' => 'Q Logic',
		'product' => 'QLA12160 on AMI MegaRAID',
		},
	'1240' => {
		'type' => 'scsi',
		'module' => 'qla1280',
		'vendor' => 'Q Logic',
		'product' => 'QLA1240',
		},
	'1280' => {
		'type' => 'scsi',
		'module' => 'qla1280',
		'vendor' => 'Q Logic',
		'product' => 'QLA1280',
		},
	'2020' => {
		'type' => 'scsi',
		'module' => 'qlogicisp',
		'vendor' => 'Q Logic',
		'product' => 'ISP2020A',
		},
	},
'107e' => {
	'0004' => {
		'type' => 'ethernet',
		'module' => 'iph5526',
		'vendor' => 'Interphase Corp.',
		'product' => '5526',
		},
	'0005' => {
		'type' => 'ethernet',
		'module' => 'iph5526',
		'vendor' => 'Interphase Corp.',
		'product' => '55x6',
		},
	'0008' => {
		'type' => 'atm',
		'module' => 'iphase',
		'vendor' => 'Interphase Corp.',
		'product' => '155 Mbit ATM Controller',
		},
	'0009' => {
		'type' => 'atm',
		'module' => 'iphase',
		'vendor' => 'Interphase Corp.',
		'product' => '5525/5575 ATM Adapter (155 Mbit) [Atlantic]',
		},
	},
'108d' => {
	'0002' => {
		'type' => 'tokenring',
		'module' => 'ibmtr',
		'vendor' => 'Olicom',
		'product' => '16/4 Token Ring',
		},
	'0004' => {
		'type' => 'tokenring',
		'module' => 'ibmtr',
		'vendor' => 'Olicom',
		'product' => 'RapidFire 3139 Token-Ring 16/4 PCI Adapter',
		},
	'0005' => {
		'type' => 'tokenring',
		'module' => 'ibmtr',
		'vendor' => 'Olicom',
		'product' => 'GoCard 3250 Token-Ring 16/4 CardBus PC Card',
		},
	'0007' => {
		'type' => 'tokenring',
		'module' => 'ibmtr',
		'vendor' => 'Olicom',
		'product' => 'RapidFire 3141 Token-Ring 16/4 PCI Fiber Adapter',
		},
	'0012' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Olicom',
		'product' => 'OC-2325',
		},
	'0013' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Olicom',
		'product' => 'OC-2183/2185',
		},
	'0014' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Olicom',
		'product' => 'OC-2326',
		},
	'0019' => {
		'type' => 'ethernet',
		'module' => 'tlan',
		'vendor' => 'Olicom',
		'product' => 'OC-2327/2250 10/100 Ethernet Adapter',
		},
	},
'108e' => {
	'1001' => {
		'type' => 'ethernet',
		'module' => 'sunhme',
		'vendor' => 'Sun',
		'product' => 'Happy Meal',
		},
	'1101' => {
		'type' => 'ethernet',
		'module' => 'sungem',
		'vendor' => 'Sun',
		'product' => 'PCIO Happy Meal Ethernet',
		},
	'2bad' => {
		'type' => 'ethernet',
		'module' => 'sungem',
		'vendor' => 'Sun',
		'product' => '',
		},
	},
'1095' => {
	'0240' => {
		'type' => 'scsi',
		'module' => 'sata_sil',
		'vendor' => 'CMD Technology Inc',
		'product' => 'Adaptec AAR-1210SA SATA HostRAID Controller',
		},
	'3112' => {
		'type' => 'scsi',
		'module' => 'sata_sil',
		'vendor' => 'Silicon Image',
		'product' => 'Sil3112A Serial ATA',
		},
	'3114' => {
		'type' => 'scsi',
		'module' => 'sata_sil',
		'vendor' => 'Silicon Image',
		'product' => 'Sil3114A Serial ATA',
		},
	'3512' => {
		'type' => 'scsi',
		'module' => 'sata_sil',
		'vendor' => 'Silicon Image',
		'product' => 'Sil3512A Serial ATA',
		},
	},
'10a9' => {
	'0009' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Silicon Graphics',
		'product' => 'Alteon Gigabit Ethernet',
		},
	},
'10b6' => {
	'0002' => {
		'type' => 'tokenring',
		'module' => 'abyss',
		'vendor' => 'Madge Networks',
		'product' => 'Smart 16/4 PCI Ringnode Mk2',
		},
	},
'10b7' => {
	'0001' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => '3Com Corp.',
		'product' => '3c985 1000BaseSX',
		},
	'1201' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '',
		},
	'1202' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '',
		},
	'1700' => {
		'type' => 'ethernet',
		'module' => 'sk98lin',
		'vendor' => '3Com Corp.',
		'product' => '3C940 10/100/1000 LAN',
		},
	'3390' => {
		'type' => 'tokenring',
		'module' => 'tmspci',
		'vendor' => '3Com Corp.',
		'product' => 'Token Link Velocity',
		},
	'3590' => {
		'type' => 'tokenring',
		'module' => '3c359',
		'vendor' => '3Com Corp.',
		'product' => '3c359 TokenLink Velocity XL',
		},
	'4500' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c450 Cyclone/unknown',
		},
	'5055' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c555 [Megahertz] 10/100 LAN CardBus',
		},
	'5057' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c575 [Megahertz] 10/100 LAN CardBus',
		},
	'5157' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c575 [Megahertz] 10/100 LAN CardBus',
		},
	'5257' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c575 Fast EtherLink XL',
		},
	'5900' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c590 10BaseT [Vortex]',
		},
	'5920' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c592 EISA 10mbps Demon/Vortex',
		},
	'5950' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c595 100BaseTX [Vortex]',
		},
	'5951' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c595 100BaseT4 [Vortex]',
		},
	'5952' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c595 100Base-MII [Vortex]',
		},
	'5970' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c597 EISA Fast Demon/Vortex',
		},
	'5b57' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3C595 Megahertz 10/100 LAN CardBus',
		},
	'6055' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c556 10/100 Mini-PCI Adapter [Cyclone]',
		},
	'6056' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3C556 10/100 Mini PCI Fast Ethernet Adapter',
		},
	'6550' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c575 [Megahertz] 10/100 LAN CardBus',
		},
	'6560' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c575 [Megahertz] 10/100 LAN CardBus',
		},
	'6561' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => 'FEM656 10/100 LAN+56K Modem CardBus PC Card',
		},
	'6562' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3CCFEM656 Cyclone CardBus',
		},
	'6563' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => 'FEM656B 10/100 LAN+56K Modem CardBus PC Card',
		},
	'6564' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3CCFEM656 Cyclone CardBus',
		},
	'7646' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3cSOHO100-TX [Hurricane]',
		},
	'7940' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c803 FDDILink DAS Controller',
		},
	'7980' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c803 FDDILink UTP Controller',
		},
	'7990' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c804 FDDILink SAS Controller',
		},
	'9000' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c900 10BaseT [Boomerang]',
		},
	'9001' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c900 Combo [Boomerang]',
		},
	'9004' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c900B-TPO [Etherlink XL TPO]',
		},
	'9005' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c900B-Combo [Etherlink XL Combo]',
		},
	'9006' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c900B-TPC [Etherlink XL TPC]',
		},
	'900a' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c900B-FL [Etherlink XL FL]',
		},
	'9050' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905 100BaseTX [Boomerang]',
		},
	'9051' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905 100BaseT4 [Boomerang]',
		},
	'9055' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905B 100BaseTX [Cyclone]',
		},
	'9056' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905B-T4 [Fast EtherLink XL 10/100]',
		},
	'9058' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905B-Combo [Deluxe Etherlink XL 10/100]',
		},
	'905a' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905B-FX [Fast Etherlink XL FX 10/100]',
		},
	'9200' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c905C-TX [Fast Etherlink]',
		},
	'9202' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3Com 3C920B-EMB-WNM Integrated Fast Ethernet Controller',
		},
	'9210' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3C920B-EMB-WNM Integrated Fast Ethernet Controller',
		},
	'9300' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => '3Com Corp.',
		'product' => '3CSOHO100B-TX  [910-A01]',
		},
	'9800' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c980-TX [Fast Etherlink XL Server Adapter]',
		},
	'9805' => {
		'type' => 'ethernet',
		'module' => '3c59x',
		'vendor' => '3Com Corp.',
		'product' => '3c980-TX [Fast Etherlink XL Server Adapter]',
		},
	'9900' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3C990-TX Typhoon',
		},
	'9902' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3CR990-TX-95 EtherLink 10/100 PCI with 3XP Processor',
		},
	'9903' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3CR990-TX-97 EtherLink 10/100 PCI with 3XP Processor',
		},
	'9904' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3CR990-TX-M EtherLink 10/100 PCI with 3XP Processor',
		},
	'9905' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3CR990-FX-95/97/95 [Typhon Fiber]',
		},
	'9908' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3CR990SVR95 EtherLink 10/100 Server PCI with 3XP',
		},
	'9909' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3CR990SVR97 EtherLink 10/100 Server PCI with 3XP',
		},
	'990a' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3C990BSVR EtherLink 10/100 Server PCI with 3XP',
		},
	'990b' => {
		'type' => 'ethernet',
		'module' => 'typhoon',
		'vendor' => '3Com Corp.',
		'product' => '3C990SVR [Typhoon Server]',
		},
	},
'10b8' => {
	'0005' => {
		'type' => 'ethernet',
		'module' => 'epic100',
		'vendor' => 'Standard Microsystems Corp [SMC]',
		'product' => '83C170QF',
		},
	'0006' => {
		'type' => 'ethernet',
		'module' => 'epic100',
		'vendor' => 'Standard Microsystems Corp [SMC]',
		'product' => 'LANEPIC',
		},
	},
'10b9' => {
	'5261' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Acer Laboratories Inc. [ALi]',
		'product' => 'M5261 Ethernet Controller',
		},
	},
'10bd' => {
	'0e34' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Surecom Technology',
		'product' => 'NE-34PCI LAN',
		},
	},
'10c3' => {
	'1100' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Samsung Semiconductors, Inc.',
		'product' => 'Smartether100 SC1100 LAN Adapter (i82557B)',
		},
	},
'10cd' => {
	'1200' => {
		'type' => 'scsi',
		'module' => 'advansys',
		'vendor' => 'Advanced System Products',
		'product' => 'ASC1200 [(abp940) Fast SCSI-II]',
		},
	'1300' => {
		'type' => 'scsi',
		'module' => 'advansys',
		'vendor' => 'Advanced System Products',
		'product' => 'ABP940-U / ABP960-U',
		},
	'2300' => {
		'type' => 'scsi',
		'module' => 'advansys',
		'vendor' => 'Advanced System Products',
		'product' => 'ABP940-UW',
		},
	'2500' => {
		'type' => 'scsi',
		'module' => 'advansys',
		'vendor' => 'Advanced System Products',
		'product' => 'ABP940-U2W',
		},
	},
'10d9' => {
	'0512' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Macronix, Inc. [MXIC]',
		'product' => 'MX98713',
		},
	'0531' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Macronix, Inc. [MXIC]',
		'product' => 'MX987x5',
		},
	'8625' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Macronix, Inc. [MXIC]',
		'product' => 'MX86250',
		},
	},
'10da' => {
	'0508' => {
		'type' => 'tokenring',
		'module' => 'tmspci',
		'vendor' => 'Compaq IPG-Austin',
		'product' => 'TC4048 Token Ring 4/16',
		},
	},
'10de' => {
	'0036' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => '',
		},
	'0037' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'0038' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'003e' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => '',
		},
	'0054' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => '',
		},
	'0055' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => '',
		},
	'0056' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'0057' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'0066' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'nForce2 MCP Networking Adapter',
		},
	'0086' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'008c' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'008e' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet controller',
		},
	'00d6' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'nForce3 MCP Networking Adapter',
		},
	'00df' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet adapter',
		},
	'00e3' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => '',
		},
	'00e6' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'Ethernet adapter',
		},
	'00ee' => {
		'type' => 'scsi',
		'module' => 'sata_nv',
		'vendor' => 'nVidia Corp.',
		'product' => '',
		},
	'01ad' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'nForce Ethernet Controller',
		},
	'01c3' => {
		'type' => 'ethernet',
		'module' => 'forcedeth',
		'vendor' => 'nVidia Corp.',
		'product' => 'nForce MCP Networking Adapter',
		},
	},
'10ec' => {
	'8029' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Realtek',
		'product' => 'RTL-8029(AS)',
		},
	'8129' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Realtek',
		'product' => 'RTL-8129',
		},
	'8138' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Realtek',
		'product' => 'RT8139 (B/C) Cardbus Fast Ethernet Adapter',
		},
	'8139' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Realtek',
		'product' => 'RTL-8139',
		},
	'8169' => {
		'type' => 'ethernet',
		'module' => 'r8169',
		'vendor' => 'Realtek',
		'product' => 'RTL-8169',
		},
	},
'10fc' => {
	'0005' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'I-O Data Device, Inc.',
		'product' => 'Cardbus SCSI CBSC II',
		},
	},
'1106' => {
	'0926' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'VIA Technologies',
		'product' => 'VT82C926 [Amazon]',
		},
	'3043' => {
		'type' => 'ethernet',
		'module' => 'via-rhine',
		'vendor' => 'VIA Technologies',
		'product' => 'VT86C100A [Rhine 10/100]',
		},
	'3053' => {
		'type' => 'ethernet',
		'module' => 'via-rhine',
		'vendor' => 'VIA Technologies',
		'product' => 'VT6105M [Rhine III 10/100]',
		},
	'3065' => {
		'type' => 'ethernet',
		'module' => 'via-rhine',
		'vendor' => 'VIA Technologies',
		'product' => 'VT6102 [Rhine II 10/100]',
		},
	'3106' => {
		'type' => 'ethernet',
		'module' => 'via-rhine',
		'vendor' => 'VIA Technologies',
		'product' => 'VT6105 [Rhine III 10/100]',
		},
	'3119' => {
		'type' => 'ethernet',
		'module' => 'via-velocity',
		'vendor' => 'VIA Technologies Inc',
		'product' => 'VT3119 Gigabit Ethernet Controller',
		},
	'3149' => {
		'type' => 'scsi',
		'module' => 'sata_via',
		'vendor' => 'VIA Technologies Inc',
		'product' => 'VT8237 SATA150 Controller',
		},
	'6100' => {
		'type' => 'ethernet',
		'module' => 'via-rhine',
		'vendor' => 'VIA Technologies',
		'product' => 'VT85C100A [Rhine II]',
		},
	},
'1113' => {
	'1211' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Accton',
		'product' => 'SMC2-1211TX',
		},
	'1216' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Accton',
		'product' => 'Ethernet Adapter',
		},
	'1217' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Accton',
		'product' => 'EN-1217 Ethernet Adapter',
		},
	'9511' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Accton',
		'product' => ' Ethernet Adapter',
		},
	},
'1119' => {
	'0000' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6000/6020/6050',
		},
	'0001' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6000b/6010',
		},
	'0002' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6110/6510',
		},
	'0003' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6120/6520',
		},
	'0004' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6530',
		},
	'0005' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6550',
		},
	'0006' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x17',
		},
	'0007' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x27',
		},
	'0008' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6537',
		},
	'0009' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 5557',
		},
	'000a' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x15',
		},
	'000b' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x25',
		},
	'000c' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6535',
		},
	'000d' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6555',
		},
	'0100' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6117RP/6517RP',
		},
	'0101' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6127RP/6527RP',
		},
	'0102' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6537RP',
		},
	'0103' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6557RP',
		},
	'0104' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6111RP/6511RP',
		},
	'0105' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6121RP/6521RP',
		},
	'0110' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6117RP1/6517RP1',
		},
	'0111' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6127RP1/6527RP1',
		},
	'0112' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6537RP1',
		},
	'0113' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6557RP1',
		},
	'0114' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6111RP1/6511RP1',
		},
	'0115' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6121RP1/6521RP1',
		},
	'0118' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x18RD',
		},
	'0119' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x28RD',
		},
	'011a' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x38RD',
		},
	'011b' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x58RD',
		},
	'0120' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6117RP2/6517RP2',
		},
	'0121' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6127RP2/6527RP2',
		},
	'0122' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6537RP2',
		},
	'0123' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6557RP2',
		},
	'0124' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6111RP2/6511RP2',
		},
	'0125' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6121RP2/6521RP2',
		},
	'0136' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6x13RS',
		},
	'0137' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6x23RS',
		},
	'0138' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6118RS/6518RS/6618RS',
		},
	'0139' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6128RS/6528RS/6628RS',
		},
	'013a' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6538RS/6638RS',
		},
	'013b' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6558RS/6658RS',
		},
	'013c' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6x33RS',
		},
	'013d' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6x43RS',
		},
	'013e' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6x53RS',
		},
	'013f' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 6x63RS',
		},
	'0166' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 7113RN/7513RN/7613RN',
		},
	'0167' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 7123RN/7523RN/7623RN',
		},
	'0168' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 7x18RN',
		},
	'0169' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 7x28RN',
		},
	'016a' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 7x38RN',
		},
	'016b' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 7x58RN',
		},
	'016c' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 7533RN/7633RN',
		},
	'016d' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 7543RN/7643RN',
		},
	'016e' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 7553RN/7653RN',
		},
	'016f' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 7563RN/7663RN',
		},
	'01d6' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 4x13RZ',
		},
	'01d7' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 4x23RZ',
		},
	'01f6' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 8x13RZ',
		},
	'01f7' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 8x23RZ',
		},
	'01fc' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 8x33RZ',
		},
	'01fd' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 8x43RZ',
		},
	'01fe' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 8x53RZ',
		},
	'01ff' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Raid Controller',
		'product' => 'GDT 8x63RZ',
		},
	'0210' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x19RD',
		},
	'0211' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 6x29RD',
		},
	'0260' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 7x19RN',
		},
	'0261' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => 'GDT 7x29RN',
		},
	'0300' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex GDT Raid Controller',
		'product' => '',
		},
	'ffff' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'ICP Vortex',
		'product' => '',
		},
	},
'111a' => {
	'0000' => {
		'type' => 'atm',
		'module' => 'eni',
		'vendor' => 'Efficient Networks, Inc',
		'product' => '155P-MF1 (FPGA)',
		},
	'0002' => {
		'type' => 'atm',
		'module' => 'eni',
		'vendor' => 'Efficient Networks, Inc',
		'product' => '155P-MF1 (ASIC)',
		},
	'0003' => {
		'type' => 'atm',
		'module' => 'lanai',
		'vendor' => 'Efficient Networks, Inc',
		'product' => 'ENI-25P ATM Adapter',
		},
	'0005' => {
		'type' => 'atm',
		'module' => 'lanai',
		'vendor' => 'Efficient Networks, Inc',
		'product' => 'ENI-25P ATM Adapter',
		},
	},
'111d' => {
	'0001' => {
		'type' => 'atm',
		'module' => 'nicstar',
		'vendor' => 'Integrated Device Tech',
		'product' => 'IDT77211 ATM Adapter',
		},
	},
'1145' => {
	'8007' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => 'NinjaSCSI-32 Workbit',
		},
	'8009' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => '',
		},
	'f007' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => 'NinjaSCSI-32 KME',
		},
	'f010' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => 'NinjaSCSI-32 Workbit',
		},
	'f012' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => 'NinjaSCSI-32 Logitec',
		},
	'f013' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => 'NinjaSCSI-32 Logitec',
		},
	'f015' => {
		'type' => 'scsi',
		'module' => 'nsp32',
		'vendor' => 'Workbit Corp.',
		'product' => 'NinjaSCSI-32 Melco',
		},
	},
'1148' => {
	'4000' => {
		'type' => 'ethernet',
		'module' => 'skfp',
		'vendor' => 'Syskonnect (Schneider & Koch)',
		'product' => 'FDDI Adapter',
		},
	'4200' => {
		'type' => 'tokenring',
		'module' => 'tmspci',
		'vendor' => 'Syskonnect (Schneider & Koch)',
		'product' => 'Token ring adaptor',
		},
	'4300' => {
		'type' => 'ethernet',
		'module' => 'sk98lin',
		'vendor' => 'Syskonnect (Schneider & Koch)',
		'product' => 'Gigabit Ethernet',
		},
	'4320' => {
		'type' => 'ethernet',
		'module' => 'sk98lin',
		'vendor' => 'Syskonnect (Schneider & Koch)',
		'product' => 'SK-98xx Gigabit Ethernet Server Adapter',
		},
	'4400' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Syskonnect (Schneider & Koch)',
		'product' => 'Tigon3 Gigabit Ethernet',
		},
	'4500' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Syskonnect (Schneider & Koch)',
		'product' => 'Tigon3 Gigabit Ethernet',
		},
	},
'114f' => {
	'0003' => {
		'type' => 'ethernet',
		'module' => 'dgrs',
		'vendor' => 'Digi International',
		'product' => 'RightSwitch SE-6',
		},
	},
'1166' => {
	'0240' => {
		'type' => 'scsi',
		'module' => 'sata_svw',
		'vendor' => 'Reliance Computer',
		'product' => 'K2 SATA controller',
		},
	'0241' => {
		'type' => 'scsi',
		'module' => 'sata_svw',
		'vendor' => '',
		'product' => '',
		},
	'0242' => {
		'type' => 'scsi',
		'module' => 'sata_svw',
		'vendor' => '',
		'product' => '',
		},
	},
'1176' => {
	'0104' => {
		'type' => 'ppp',
		'module' => 'wanxl',
		'vendor' => 'SBE Inc',
		'product' => 'WanXL100 Adapter',
		},
	'0301' => {
		'type' => 'ppp',
		'module' => 'wanxl',
		'vendor' => 'SBE Inc',
		'product' => 'WanXL200 Adapter',
		},
	'0302' => {
		'type' => 'ppp',
		'module' => 'wanxl',
		'vendor' => 'SBE Inc',
		'product' => 'WanXL400 Adapter',
		},
	},
'1186' => {
	'0100' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'D-Link System Inc',
		'product' => 'DC21041',
		},
	'1002' => {
		'type' => 'ethernet',
		'module' => 'sundance',
		'vendor' => 'D-Link Inc',
		'product' => 'DFE 550 TX',
		},
	'1100' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'D-Link Inc',
		'product' => 'Fast Ethernet Adapter',
		},
	'1300' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'D-Link Inc',
		'product' => 'DFE 530 TX+ Fast Ethernet Adapter',
		},
	'1340' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'D-Link Inc',
		'product' => 'DFE-690TXD (CardBus PC Card)',
		},
	'1541' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'D-Link System Inc',
		'product' => 'DFE-680TXD CardBus PC Card',
		},
	'1561' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'D-Link System Inc',
		'product' => 'DRP-32TXD Cardbus PC Card',
		},
	'4000' => {
		'type' => 'ethernet',
		'module' => 'dl2k',
		'vendor' => 'D-Link Inc',
		'product' => ' Ethernet Adapter',
		},
	},
'1191' => {
	'8002' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'Artop Electronic Corp',
		'product' => 'AEC6710 SCSI-2 Host Adapter',
		},
	'8010' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'Artop Electronic Corp',
		'product' => 'AEC6712UW SCSI',
		},
	'8020' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'Artop Electronic Corp',
		'product' => 'AEC6712U SCSI',
		},
	'8030' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'Artop Electronic Corp',
		'product' => 'AEC6712S SCSI',
		},
	'8040' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'Artop Electronic Corp',
		'product' => 'AEC6712D SCSI',
		},
	'8050' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'Artop Electronic Corp',
		'product' => 'AEC6712SUW SCSI',
		},
	'8060' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'ACARD Technology',
		'product' => 'AEC671x SCSI Host Adapter',
		},
	'8081' => {
		'type' => 'scsi',
		'module' => 'atp870u',
		'vendor' => 'ACARD Technology',
		'product' => 'AEC-67160 PCI Ultra160 LVD/SE SCSI Adapter',
		},
	},
'119e' => {
	'0001' => {
		'type' => 'atm',
		'module' => 'firestream',
		'vendor' => 'Fujitsu Microelectronics Europe GMBH',
		'product' => 'FireStream 155',
		},
	'0003' => {
		'type' => 'atm',
		'module' => 'firestream',
		'vendor' => 'Fujitsu Microelectronics Europe GMBH',
		'product' => 'FireStream 50',
		},
	},
'11ab' => {
	'4320' => {
		'type' => 'ethernet',
		'module' => 'sk98lin',
		'vendor' => 'Marvell Semiconductor, Inc.',
		'product' => '88E8001 Gigabit Lan PCI Controller',
		},
	},
'11ad' => {
	'0002' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Lite-On',
		'product' => 'LNE100TX',
		},
	'c115' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Lite-On',
		'product' => 'LC82C115 PNIC-II',
		},
	},
'11b0' => {
	'0002' => {
		'type' => 'ppp',
		'module' => 'sdladrv',
		'vendor' => 'V3 Semiconductor Inc.',
		'product' => 'V300PSC',
		},
	},
'11db' => {
	'1234' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Sega Enterprises Ltd',
		'product' => 'Dreamcast Broadband Adapter',
		},
	},
'11f6' => {
	'0112' => {
		'type' => 'ethernet',
		'module' => 'hp100',
		'vendor' => 'Compex',
		'product' => 'ENet100VG4',
		},
	'1401' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Compex',
		'product' => 'ReadyLink 2000',
		},
	'2201' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Compex',
		'product' => 'ReadyLink 100TX (Winbond W89C840)',
		},
	'9881' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Compex',
		'product' => 'RL100TX',
		},
	},
'120f' => {
	'0001' => {
		'type' => 'ethernet',
		'module' => 'rrunner',
		'vendor' => 'Essential Communications',
		'product' => 'Roadrunner serial HIPPI',
		},
	},
'1256' => {
	'4201' => {
		'type' => 'scsi',
		'module' => 'pci2220i',
		'vendor' => 'Perceptive Solutions, Inc.',
		'product' => 'PCI-2220I',
		},
	'4401' => {
		'type' => 'scsi',
		'module' => 'pci2220i',
		'vendor' => 'Perceptive Solutions, Inc.',
		'product' => 'PCI-2240I',
		},
	'5201' => {
		'type' => 'scsi',
		'module' => 'pci2000',
		'vendor' => 'Perceptive Solutions, Inc.',
		'product' => 'PCI-2000',
		},
	},
'1259' => {
	'2560' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Allied Telesyn International',
		'product' => 'AT-2560 Fast Ethernet Adapter (i82557B)',
		},
	'a117' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Allied Telesyn International',
		'product' => 'RTL8139 CardBus',
		},
	'a11e' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Allied Telesyn International',
		'product' => '',
		},
	'a120' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Allied Telesyn International',
		'product' => '',
		},
	},
'125b' => {
	'1400' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'ASIX',
		'product' => 'AX88140',
		},
	},
'1266' => {
	'0001' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Microdyne Corp.',
		'product' => 'NE10/100 Adapter (i82557B)',
		},
	},
'126c' => {
	'1211' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Nortel Networks Corp.',
		'product' => '',
		},
	},
'1282' => {
	'9100' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Davicom',
		'product' => 'DM9100',
		},
	'9102' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Davicom',
		'product' => 'Ethernet 100/10 MBit DM9102',
		},
	},
'12ae' => {
	'0001' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Alteon Networks Inc.',
		'product' => 'AceNIC Gigabit Ethernet',
		},
	'0002' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Alteon Networks Inc.',
		'product' => 'AceNIC Gigabit Ethernet (Copper)',
		},
	'00fa' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Alteon Networks Inc.',
		'product' => 'AceNIC PN9100T Fast Ethernet (Copper)',
		},
	},
'12c3' => {
	'0058' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Holtek Microelectronics Inc.',
		'product' => 'Ethernet Adapter',
		},
	'5598' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Holtek Microelectronics Inc.',
		'product' => 'Ethernet Adapter',
		},
	},
'1317' => {
	'0981' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'ADMtek',
		'product' => 'AN981 Comet',
		},
	'0985' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'ADMtek',
		'product' => 'ADM983 Linksys EtherFast 10/100',
		},
	'1985' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'ADMtek',
		'product' => 'ADM985 10/100 cardbus ethernet controller',
		},
	'9511' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Admtek Inc',
		'product' => 'ADM9511 cardbus ethernet-modem controller',
		},
	},
'1318' => {
	'0911' => {
		'type' => 'ethernet',
		'module' => 'hamachi',
		'vendor' => 'Packet Engines Inc.',
		'product' => 'PCI Ethernet Adapter',
		},
	},
'1332' => {
	'5415' => {
		'type' => 'scsi',
		'module' => 'umem',
		'vendor' => 'Micro Memory',
		'product' => 'MM-5415CN PCI Memory Module with Battery Backup',
		},
	'5425' => {
		'type' => 'scsi',
		'module' => 'umem',
		'vendor' => 'Micro Memory',
		'product' => 'MM-5425CN PCI 64/66 Memory Module with Battery Backup',
		},
	'6155' => {
		'type' => 'scsi',
		'module' => 'umem',
		'vendor' => 'Micro Memory',
		'product' => '',
		},
	},
'134a' => {
	'0001' => {
		'type' => 'scsi',
		'module' => 'dtc',
		'vendor' => 'DTC Technology Corp.',
		'product' => 'Domex 536',
		},
	'0002' => {
		'type' => 'scsi',
		'module' => 'dtc',
		'vendor' => 'DTC Technology Corp.',
		'product' => 'Domex DMX3194UP SCSI Adapter',
		},
	},
'1385' => {
	'620a' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Netgear',
		'product' => 'GA620',
		},
	'630a' => {
		'type' => 'ethernet',
		'module' => 'acenic',
		'vendor' => 'Netgear',
		'product' => 'GA630',
		},
	},
'13c1' => {
	'1000' => {
		'type' => 'scsi',
		'module' => '3w-xxxx',
		'vendor' => '3ware Inc',
		'product' => '3ware ATA-RAID',
		},
	'1001' => {
		'type' => 'scsi',
		'module' => '3w-xxxx',
		'vendor' => '3ware Inc',
		'product' => '3ware 7000-series ATA-RAID',
		},
	'1002' => {
		'type' => 'scsi',
		'module' => '3w-9xxx',
		'vendor' => '3ware Inc',
		'product' => '3ware 9XXX-series ATA-RAID',
		},
	},
'13d1' => {
	'ab02' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Abocom Systems Inc',
		'product' => 'Ethernet Adapter',
		},
	'ab03' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Abocom Systems Inc',
		'product' => 'Ethernet Adapter',
		},
	'ab06' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Abocom Systems Inc',
		'product' => 'FE2000VX CardBus /Atelco Fibreline Ethernet Adptr',
		},
	'ab08' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Abocom Systems Inc',
		'product' => 'Ethernet Adapter',
		},
	},
'13f0' => {
	'0201' => {
		'type' => 'ethernet',
		'module' => 'sundance',
		'vendor' => 'Sundance Technology Inc',
		'product' => 'ST201 Fast Ehternet Adapter',
		},
	},
'1400' => {
	'1401' => {
		'type' => 'ethernet',
		'module' => 'epic100',
		'vendor' => 'Standard Microsystems Corp [SMC]',
		'product' => '9432 TX',
		},
	},
'1432' => {
	'9130' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Edimax Computer Co.',
		'product' => 'RTL81xx Fast Ethernet',
		},
	},
'14e4' => {
	'1644' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5700 1000BaseTX',
		},
	'1645' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5701 1000BaseTX',
		},
	'1646' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5702 Gigabit Ethernet',
		},
	'1647' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5701 1000BaseTX',
		},
	'1648' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5704 CIOB-E 1000BaseTX',
		},
	'1649' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5704S 1000BaseTX',
		},
	'164d' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5702FE Gigabit Ethernet',
		},
	'1653' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5705 Gigabit Ethernet',
		},
	'1654' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5705-2 Gigabit Ethernet',
		},
	'1658' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => '',
		},
	'1659' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5721 Gigabit Ethernet PCI Express',
		},
	'165d' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5705M 1000BaseTX',
		},
	'165e' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5705M-2 1000BaseTX',
		},
	'166e' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM5705F 1000BaseTX',
		},
	'1676' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => '',
		},
	'1677' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5751 Gigabit Ethernet PCI Express',
		},
	'167c' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => '',
		},
	'167d' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => '',
		},
	'167e' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => '',
		},
	'1696' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5782 Gigabit Ethernet',
		},
	'169c' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5788 Gigabit Ethernet',
		},
	'169d' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => '',
		},
	'16a6' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5702X Gigabit Ethernet',
		},
	'16a7' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5703X Gigabit Ethernet',
		},
	'16a8' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5704X Gigabit Ethernet',
		},
	'16c6' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5702 Gigabit Ethernet',
		},
	'16c7' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5703 Gigabit Ethernet',
		},
	'170c' => {
		'type' => 'ethernet',
		'module' => 'b44',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM4401-B0 100Base-TX',
		},
	'170d' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5700 Ethernet',
		},
	'170e' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Broadcom Corp.',
		'product' => 'NetXtreme BCM5700 Ethernet',
		},
	'4401' => {
		'type' => 'ethernet',
		'module' => 'b44',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM4401 100Base-T',
		},
	'4402' => {
		'type' => 'ethernet',
		'module' => 'b44',
		'vendor' => 'Broadcom Corp.',
		'product' => 'BCM4402 Integrated 10/100BaseT',
		},
	'4713' => {
		'type' => 'ethernet',
		'module' => 'b44',
		'vendor' => 'Broadcom Corp.',
		'product' => 'Sentry5 Ethernet Controller',
		},
	},
'14ea' => {
	'ab06' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Planex Communications, Inc',
		'product' => 'FNW-3603-TX CardBus Fast Ethernet',
		},
	'ab07' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Planex Communications, Inc',
		'product' => 'RTL81xx RealTek Ethernet',
		},
	},
'14f1' => {
	'1803' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Conexant',
		'product' => 'LANfinity',
		},
	},
'1500' => {
	'1360' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Delta Electronics',
		'product' => '8139 10/100BaseTX',
		},
	},
'1516' => {
	'0800' => {
		'type' => 'ethernet',
		'module' => 'fealnx',
		'vendor' => 'Myson Technology Inc',
		'product' => '800 network controller',
		},
	'0803' => {
		'type' => 'ethernet',
		'module' => 'fealnx',
		'vendor' => 'Myson Technology Inc',
		'product' => '803 network controller',
		},
	'0891' => {
		'type' => 'ethernet',
		'module' => 'fealnx',
		'vendor' => 'Myson Technology Inc',
		'product' => '891 network controller',
		},
	},
'1619' => {
	'0400' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync T2P two Port Intelligent Sync Comms Card',
		},
	'0440' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync T4P Four Port Intelligent Sync Comms Card',
		},
	'0610' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync T1U One Port Intelligent Sync Comms Card',
		},
	'0620' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync T2U Two Port Intelligent Sync Comms Card',
		},
	'0640' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync T4U Four Port Intelligent Sync Comms Card',
		},
	'1610' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync TE1 One Port Intelligent Sync Comms Card',
		},
	'1612' => {
		'type' => 'ppp',
		'module' => 'farsync',
		'vendor' => 'FarSite Communications Limited',
		'product' => 'FarSync TE1C Channelized Intelligent Sync Comms Card',
		},
	},
'1626' => {
	'8410' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'TDK Semiconductor Corp.',
		'product' => 'RTL81xx Fast Ethernet',
		},
	},
'1725' => {
	'7174' => {
		'type' => 'scsi',
		'module' => 'sata_vsc',
		'vendor' => 'Vitesse Semiconductor',
		'product' => 'VSC7174 PCI/PCI-X Serial ATA Host Bus Controller',
		},
	},
'1737' => {
	'ab08' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Linksys',
		'product' => '21x4x DEC-Tulip compatible 10/100 Ethernet',
		},
	'ab09' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Linksys',
		'product' => '21x4x DEC-Tulip compatible 10/100 Ethernet',
		},
	},
'173b' => {
	'03e8' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Altima (nee BroadCom)',
		'product' => 'AC1000 Gigabit Ethernet',
		},
	'03e9' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Altima (nee BroadCom)',
		'product' => 'AC1000 Gigabit Ethernet',
		},
	'03ea' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Altima (nee BroadCom)',
		'product' => 'AC1000 Gigabit Ethernet',
		},
	'03eb' => {
		'type' => 'ethernet',
		'module' => 'tg3',
		'vendor' => 'Altima (nee BroadCom)',
		'product' => 'AC1000 Gigabit Ethernet',
		},
	},
'1743' => {
	'8139' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Peppercon AG',
		'product' => 'ROL/F-100 Fast Ethernet Adapter with ROL',
		},
	},
'17b3' => {
	'ab08' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Hawking Technologies',
		'product' => 'PN672TX 10/100 Ethernet',
		},
	},
'17d5' => {
	'5731' => {
		'type' => 'ethernet',
		'module' => 's2io',
		'vendor' => '',
		'product' => '',
		},
	'5831' => {
		'type' => 'ethernet',
		'module' => 's2io',
		'vendor' => '',
		'product' => '',
		},
	},
'1d44' => {
	'a400' => {
		'type' => 'scsi',
		'module' => 'eata',
		'vendor' => 'DPT',
		'product' => 'PM2x24/PM3224',
		},
	},
'4033' => {
	'1360' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'Addtron Technology',
		'product' => '8139 10/100BaseTX',
		},
	},
'4a14' => {
	'5000' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'NetVin',
		'product' => 'NV5000SC',
		},
	},
'8086' => {
	'0039' => {
		'type' => 'ethernet',
		'module' => 'tulip',
		'vendor' => 'Intel Corp.',
		'product' => '21145',
		},
	'0600' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'Intel Corp.',
		'product' => 'RAID Controller',
		},
	'0601' => {
		'type' => 'scsi',
		'module' => 'gdth',
		'vendor' => 'Intel Corp.',
		'product' => '',
		},
	'1000' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82542 Gigabit Ethernet Adapter',
		},
	'1001' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82543 Gigabit Ethernet Adapter',
		},
	'1002' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'Pro 100 LAN+Modem 56 CardBus II',
		},
	'1004' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => ' Gigabit Ethernet Adapter',
		},
	'1008' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82544EI Gigabit Ethernet Controller',
		},
	'1009' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82544EI Gigabit Ethernet Controller',
		},
	'100c' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82544GC Gigabit Ethernet Controller',
		},
	'100d' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82544GC Gigabit Ethernet Controller',
		},
	'100e' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82540EM Gigabit Ethernet Controller',
		},
	'100f' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82545EM Gigabit Ethernet Controller',
		},
	'1010' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82546EB Gigabit Ethernet Controller',
		},
	'1011' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82545EM Gigabit Ethernet Controller',
		},
	'1012' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82546EB Gigabit Ethernet Controller',
		},
	'1013' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82541EI Gigabit Ethernet Controller',
		},
	'1014' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82541ER Gigabit Ethernet Controller',
		},
	'1015' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82540EM Gigabit Ethernet Controller (LOM)',
		},
	'1016' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82540EP Gigabit Ethernet Controller (LOM)',
		},
	'1017' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82540EP Gigabit Ethernet Controller (LOM)',
		},
	'1018' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82541EI PRO/1000 MT Mobile connection',
		},
	'1019' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82547EI Gigabit Ethernet Controller',
		},
	'101d' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82540EM Gigabit Ethernet Controller (LOM)',
		},
	'101e' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82540EP Gigabit Ethernet Controller (Mobile)',
		},
	'1026' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82545GM Gigabit Ethernet Controller',
		},
	'1027' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82545GM Gigabit Ethernet Controller (Fiber)',
		},
	'1028' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82545GM Gigabit Ethernet Controller',
		},
	'1029' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'Express Pro 100',
		},
	'1030' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82559 InBusiness 10/100',
		},
	'1031' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Express Pro 100',
		},
	'1032' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Express Pro 100',
		},
	'1033' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Express Pro 100',
		},
	'1034' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Express Pro 100',
		},
	'1035' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801CAM (ICH3) Chipset Ethernet Controller',
		},
	'1036' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801CAM (ICH3) Chipset Ethernet Controller',
		},
	'1037' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801CAM (ICH3) Chipset Ethernet Controller',
		},
	'1038' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Express Pro 100',
		},
	'1039' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'103a' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'103b' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'103c' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'103d' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801BD PRO/100 VE (MOB) Ethernet Controller',
		},
	'103e' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801BD PRO/100 VM (MOB) Ethernet Controller',
		},
	'1048' => {
		'type' => 'ethernet',
		'module' => 'ixgb',
		'vendor' => 'Intel Corp.',
		'product' => '82597EX 10 Gigabit Ethernet Controller',
		},
	'1050' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB (ICH5) PRO/100 VE Ethernet Controller',
		},
	'1051' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB (ICH5) PRO/100 VE Ethernet Controller',
		},
	'1052' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB (ICH5) PRO/100 VM Ethernet Controller',
		},
	'1053' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB (ICH5) PRO/100 VM Ethernet Controller',
		},
	'1054' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB (ICH5) PRO/100 VE Ethernet Controller',
		},
	'1055' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB (ICH5) PRO/100 VM Ethernet Controller',
		},
	'1059' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82551QM Ethernet Controller',
		},
	'1064' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'1065' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => '82801FB/FBM/FR/FW/FRW (ICH6 Family) LAN Controller',
		},
	'1066' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'1067' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'1068' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'1069' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'106a' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'106b' => {
		'type' => 'ethernet',
		'module' => 'e100',
		'vendor' => 'Intel Corp.',
		'product' => 'Ethernet Controller',
		},
	'1075' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82547EI Gigabit Ethernet Controller',
		},
	'1076' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82547EI Gigabit Ethernet Controller',
		},
	'1077' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82547EI Gigabit Ethernet Controller(Mobile)',
		},
	'1078' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82547EI Gigabit Ethernet Controller',
		},
	'1079' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82546EB Dual Port Gigabit Ethernet Controller',
		},
	'107a' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82546EB Dual Port Gigabit Ethernet Controller (Fiber)',
		},
	'107b' => {
		'type' => 'ethernet',
		'module' => 'e1000',
		'vendor' => 'Intel Corp.',
		'product' => '82546EB Dual Port Gigabit Ethernet Controller (Copper)',
		},
	'1209' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82559ER',
		},
	'1227' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82865 [Ether Express Pro 100]',
		},
	'1228' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82556 [Ether Express Pro 100 Smart]',
		},
	'1229' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82559 [Ethernet Pro 100]',
		},
	'1960' => {
		'type' => 'scsi',
		'module' => 'megaraid',
		'vendor' => 'Intel Corp.',
		'product' => '80960RP [i960RP Microprocessor]',
		},
	'1a48' => {
		'type' => 'ethernet',
		'module' => 'ixgb',
		'vendor' => 'Intel Corp.',
		'product' => '',
		},
	'2449' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'2459' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801E Ethernet Controller 0',
		},
	'245d' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => '82801E Ethernet Controller 1',
		},
	'24d1' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB ICH5 IDE (SATA)',
		},
	'24db' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => '82801EB ICH5 IDE',
		},
	'24df' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => '82801ER ICH5 IDE (SATA Raid)',
		},
	'25a2' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => 'Enterprise Southbridge PATA',
		},
	'25a3' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => 'IDE (SATA)',
		},
	'25b0' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => 'IDE (SATA)',
		},
	'2651' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => '82801FB/FW (ICH6/ICH6W) SATA Controller',
		},
	'2652' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => '82801FR/FRW (ICH6R/ICH6RW) SATA Controller',
		},
	'2653' => {
		'type' => 'scsi',
		'module' => 'ata_piix',
		'vendor' => 'Intel Corp.',
		'product' => '82801FBM (ICH6M) SATA Controller',
		},
	'3200' => {
		'type' => 'scsi',
		'module' => 'sata_vsc',
		'vendor' => 'Intel Corp.',
		'product' => '31244 PCI-X to Serial ATA Controller',
		},
	'5200' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'5201' => {
		'type' => 'ethernet',
		'module' => 'eepro100',
		'vendor' => 'Intel Corp.',
		'product' => 'EtherExpress PRO/100',
		},
	'b555' => {
		'type' => 'scsi',
		'module' => 'umem',
		'vendor' => 'Intel Corp.',
		'product' => '21555 Non-Transparent PCI-to-PCI Bridge',
		},
	},
'8c4a' => {
	'1980' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'Winbond',
		'product' => 'W89C940 misprogrammed [ne2k]',
		},
	},
'8e2e' => {
	'3000' => {
		'type' => 'ethernet',
		'module' => 'ne2k-pci',
		'vendor' => 'KTI',
		'product' => 'ET32P2',
		},
	},
'9004' => {
	'1078' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7810',
		},
	'2178' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7821',
		},
	'3860' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2930CU',
		},
	'5075' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-755x',
		},
	'5078' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-7850',
		},
	'5175' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-755x',
		},
	'5178' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7851',
		},
	'5275' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-755x',
		},
	'5278' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7852',
		},
	'5375' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-755x',
		},
	'5378' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7850',
		},
	'5475' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-2930',
		},
	'5478' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7850',
		},
	'5575' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AVA-2930',
		},
	'5578' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7855',
		},
	'5675' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-755x',
		},
	'5678' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7850',
		},
	'5775' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-755x',
		},
	'5778' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7850',
		},
	'5800' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-5800',
		},
	'6038' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-3860',
		},
	'6075' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-1480 / APA-1480',
		},
	'6078' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7860',
		},
	'6178' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7861',
		},
	'6278' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7860',
		},
	'6378' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7860',
		},
	'6478' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-786',
		},
	'6578' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-786x',
		},
	'6678' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-786',
		},
	'6778' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-786x',
		},
	'6915' => {
		'type' => 'ethernet',
		'module' => 'starfire',
		'vendor' => 'Adaptec',
		'product' => 'ANA620xx/ANA69011A Fast Ethernet',
		},
	'7078' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-294x / AIC-7870',
		},
	'7178' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-294x / AIC-7871',
		},
	'7278' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3940 / AIC-7872',
		},
	'7378' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3985 / AIC-7873',
		},
	'7478' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2944 / AIC-7874',
		},
	'7578' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3944 / AHA-3944W / 7875',
		},
	'7678' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-4944W/UW / 7876',
		},
	'7778' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-787x',
		},
	'7810' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7810',
		},
	'7815' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7815 RAID+Memory Controller IC',
		},
	'7850' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7850',
		},
	'7855' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2930',
		},
	'7860' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7860',
		},
	'7870' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7870',
		},
	'7871' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2940',
		},
	'7872' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3940',
		},
	'7873' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3980',
		},
	'7874' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2944',
		},
	'7880' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7880P',
		},
	'7890' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7890',
		},
	'7891' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-789x',
		},
	'7892' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-789x',
		},
	'7893' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-789x',
		},
	'7894' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-789x',
		},
	'7895' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2940U/UW / AHA-39xx / AIC-7895',
		},
	'7896' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-789x',
		},
	'7897' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-789x',
		},
	'8078' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7880U',
		},
	'8178' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7881U',
		},
	'8278' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3940U/UW / AIC-7882U',
		},
	'8378' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3940U/UW / AIC-7883U',
		},
	'8478' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-294x / AIC-7884U',
		},
	'8578' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-3944U / AHA-3944UWD / 7885',
		},
	'8678' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-4944UW / 7886',
		},
	'8778' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-788x',
		},
	'8878' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7888',
		},
	'8b78' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'ABA-1030',
		},
	'ec78' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-4944W/UW',
		},
	'ffff' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Unknown Vendor',
		'product' => 'AIC7xxx compatible SCSI controller',
		},
	},
'9005' => {
	'0010' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2940U2/W',
		},
	'0011' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '2930U2',
		},
	'0013' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '78902',
		},
	'001f' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AHA-2940U2/W / 7890',
		},
	'0020' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7890',
		},
	'002f' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7890',
		},
	'0030' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7890',
		},
	'003f' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7890',
		},
	'0050' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '3940U2',
		},
	'0051' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '3950U2D',
		},
	'0053' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC-7896 SCSI Controller',
		},
	'005f' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7896',
		},
	'0080' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7892A',
		},
	'0081' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7892B',
		},
	'0083' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7892D',
		},
	'008f' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7892P',
		},
	'00c0' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7899A',
		},
	'00c1' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7899B',
		},
	'00c3' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7899D',
		},
	'00cf' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => '7899P',
		},
	'0250' => {
		'type' => 'scsi',
		'module' => 'ips',
		'vendor' => 'Adaptec',
		'product' => 'ServeRAID Controller',
		},
	'0283' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Adaptec',
		'product' => 'AAC RAID',
		},
	'0284' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Adaptec',
		'product' => 'AAC RAID',
		},
	'0285' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Adaptec',
		'product' => 'AAC RAID',
		},
	'0286' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Adaptec',
		'product' => 'AAC-RAID (Rocket)',
		},
	'1364' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Adaptec',
		'product' => 'Dell PowerEdge RAID Controller 2',
		},
	'1365' => {
		'type' => 'scsi',
		'module' => 'aacraid',
		'vendor' => 'Adaptec',
		'product' => 'Dell PowerEdge RAID Controller 2',
		},
	'ffff' => {
		'type' => 'scsi',
		'module' => 'aic7xxx',
		'vendor' => 'Adaptec',
		'product' => 'AIC7xxx compatible SCSI controller',
		},
	},
'ffff' => {
	'8139' => {
		'type' => 'ethernet',
		'module' => '8139too',
		'vendor' => 'RealTek',
		'product' => 'RTL-8139 Fast Ethernet',
		},
	},

        };

1;

