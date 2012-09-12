use ExtUtils::MakeMaker;
use Carp;

###
#  Version is set here globally so we can be more tricky with it
###

my $version = '2.2.11';

sub MY::postamble {
    my $string = <<EOF;

POD2MAN_EXE := \$(POD2MAN_EXE) "--center=System Configurator" "--release=v$version"
POD2MAN5_EXE = \$(POD2MAN_EXE) "--section=5"

deb_prep :: manifest
\tperl -pi.bak -e 's/^VERSION.*/VERSION = $version/' debian/rules

deb :: deb_prep dist
\tmkdir -p /tmp/scdeb
\tmv systemconfigurator-$version.tar.gz /tmp/scdeb && cd /tmp/scdeb && tar -xvzf systemconfigurator-$version.tar.gz && cd systemconfigurator-$version && dpkg-buildpackage && rm -rf /tmp/scdeb/systemconfigurator-$version
\techo "Debian Packages have been built in /tmp/scdeb"

rpm_prep ::
\tcp -a ./sc.spec.in ./sc.spec && perl -pi -e 's/\\\@VERSION@/$version/' ./sc.spec

rpm :: srpm 
\trpmbuild -tb \$(NAME)-\$(VERSION).tar.gz

srpm :: rpm_prep manifest dist
\trpmbuild -ts \$(NAME)-\$(VERSION).tar.gz

manext_install ::
\tcd docs && \\
\tinstall -d \$(DESTDIR)\$(INSTALLMAN1DIR)/../man5 && \\
\t\$(POD2MAN5_EXE) systemconfig.conf.pod \$(DESTDIR)\$(INSTALLMAN1DIR)/../man5/systemconfig.conf.5 && \\
\tcd ..

set_ver::
\tperl -pi -e 's/EXEVERSION =.*/EXEVERSION = "$version";/' ./blib/script/systemconfigurator
\tperl -pi -e 's/EXEVERSION =.*/EXEVERSION = "$version";/' ./bin/systemconfigurator
\tcp -a ./sc.spec.in ./sc.spec && perl -pi -e 's/\\\@VERSION@/$version/' ./sc.spec

all :: set_ver manifest

install :: manext_install

EOF
}

WriteMakefile(
              'VERSION' => $version,
              'NAME' => 'systemconfigurator',
              'EXE_FILES' => [qw(bin/systemconfigurator
				 bin/scconf-tool
				 bin/scconf-bootinfo
				)],
              'MAN1PODS' => {
                             'bin/systemconfigurator' => '$(INST_MAN1DIR)/systemconfigurator.$(MAN1EXT)',
                            },
              # get rid of the man 3 pages, as they are pretty useless
              'MAN3PODS' => {
                            },
              'macro' => {
                          'MAN1EXT' => '1',
                          'MAN3EXT' => '3pm',
                         },
              'INSTALLSITELIB' => '/usr/lib/systemconfig',
              'PREREQ_PM' => {
                              AppConfig => 1.52,
                             },
              'realclean' => {FILES => "*.old *.bak *.tar.gz *.yml *.spec Makefile MANIFEST"},
             );
