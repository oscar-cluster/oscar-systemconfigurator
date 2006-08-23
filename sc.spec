%define prefix          /usr

Summary: System Configurator
Name: systemconfigurator
Version: 2.2.5
Release: 12ef
License: GPL
URL: http://systemconfig.sourceforge.net
Group: Applications/System
Source: %{name}-%{version}.tar.gz
Requires: perl perl-AppConfig
Vendor: Open Cluster Group
Distribution: OSCAR
Packager: Erich Focht <efocht@hpce.nec.com>
Prefix: %prefix
Buildroot: /var/tmp/%{name}-%{version}-root
BuildArchitectures: noarch
AutoReqProv: no

%description
Unified Configuration API for Linux Installation

Provides an API for various installation and configuration processes that are
otherwise inconsistent between the many Linux distributions, and the many
architectures they run on.  For example, you can configure the bootloader
on a system in a general way - you don't need to know anything about the
particular boot loader on the system.  You can update the network settings
of a system, without knowing the distribution or the format of its network
configuration files.

%prep
%setup -q


# No configure, no make, just copy files to the output dir.
%build
cd $RPM_BUILD_DIR/%{name}-%{version}
mkdir -p /var/tmp/%{name}-%{version}-root/usr/share/man/man5
mv Makefile.PL Makefile.PL_old
sed -e "s/versionxyz/%{version}/" < Makefile.PL_old > Makefile.PL
rm -f Makefile.PL_old
perl Makefile.PL PREFIX=/var/tmp/%{name}-%{version}-root%{prefix} INSTALLSITELIB=/var/tmp/%{name}-%{version}-root/usr/lib/systemconfig INSTALLMAN1DIR=/var/tmp/%{name}-%{version}-root/usr/share/man/man1 INSTALLMAN3DIR=/var/tmp/%{name}-%{version}-root/usr/share/man/man3 INSTALLSITEMAN1DIR=/var/tmp/%{name}-%{version}-root/usr/share/man/man1 INSTALLSITEMAN3DIR=/var/tmp/%{name}-%{version}-root/usr/share/man/man3 INSTALLSITEBIN=/var/tmp/%{name}-%{version}-root/usr/bin INSTALLSITESCRIPT=/var/tmp/%{name}-%{version}-root/usr/bin
make
make test
make install
#gzip /var/tmp/%{name}-%{version}-root/usr/share/man/*/*
rm -rf /var/tmp/%{name}-%{version}-root/usr/lib/systemconfig/auto*
find /var/tmp/%{name}-%{version}-root/ -name perllocal.pod | xargs rm -f

%clean
rm -rf /var/tmp/%{name}-%{version}-root

%files
%defattr(-,root,root)
%doc TODO 
%doc CREDITS 
%doc CHANGELOG 
%doc README
%doc INSTALL 
%doc README.yaboot
%doc COPYING
%doc sample.cfg
%doc docs/design.pod 
%{prefix}/bin/*
%{prefix}/share/man/man1/*
%{prefix}/share/man/man5/*
/usr/lib/systemconfig/*
%dir /usr/lib/systemconfig

%changelog
* Wed Aug 23 2006 Erich Focht
- added cechk for --no-floppy support of grub (RHEL3 doesn't support it)
- made functions in Grub.pm more OO. Needed for storing "nofloppy" capability
  centrally, in the object instance.
* Mon Aug 07 2006 Erich Focht
- added --no-floppy to grub calls as suggested by Andrea Righi.
- version 2.2.4
* Mon Jul 17 2006 Erich Focht
- added <HOSTID>, <HOSTID+nnn> and <HOSTID-nnn> hostname dependent
  variable replacement (in the global APPEND block of the BOOT section).
- version 2.2.3-11ef
* Tue Mar 07 2006 Erich Focht <efocht@hpce.nec.com>
- repackaging, eliminating additional patches
- cleaning up build directory structure
* Wed Aug 24 2005 Erich Focht <efocht@hpce.nec.com>
- 2.2.2-11ef : bad device files created for md devices,
  fixing by dereferencing the copies in Initrd/RH.pm.

* Mon Jul 18 2005 Erich Focht <efocht@hpce.nec.com>
- 2.2.2-10ef : added devfs fix for udev style devices

* Wed Jul 13 2005 Erich Focht <efocht@hpce.nec.com>
- 2.2.2-8ef :OSCAR version with ia64 efi and other fixes

* Tue Aug 21 2001 Sean Dague <japh@us.ibm.com>
- Added %doc sections for devel docs

* Tue Aug 14 2001 Sean Dague <japh@us.ibm.com>
- Added prebuild for man 5 directory

* Mon Jul 16 2001 Sean Dague <japh@us.ibm.com>
- Initial spec file.
