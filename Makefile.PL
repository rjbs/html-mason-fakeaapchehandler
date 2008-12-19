use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HTML::Mason::FakeApacheHandler',
    AUTHOR              => 'Hans Dieter Pearcey <hdp@cpan.org>',
    VERSION_FROM        => 'lib/HTML/Mason/FakeApacheHandler.pm',
    ABSTRACT_FROM       => 'lib/HTML/Mason/FakeApacheHandler.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'HTML::Mason' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HTML-Mason-FakeApacheHandler-*' },
);
