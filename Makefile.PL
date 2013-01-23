use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Webservice::Instagram',
    AUTHOR              => q{Daya Sagar Nune <dayanune@cpan.org>},
    VERSION_FROM        => 'lib/Webservice/Instagram.pm',
    ABSTRACT_FROM       => 'lib/Webservice/Instagram.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Webservice-Instagram-*' },
);
