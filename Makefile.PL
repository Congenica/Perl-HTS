use ExtUtils::MakeMaker;
#WriteMakefile(
#			  NAME         => 'Tabix',
#			  VERSION_FROM => 'Tabix.pm',
#			  LIBS         => ['-L.. -ltabix -lz'],
#			  DEFINE       => '-D_FILE_OFFSET_BITS=64 -D_USE_KNETFILE',
#			  INC          => '-I..',
#			 );

#To link against htslib we need to make a few changes (linking to tbx.h rather than tabix.h)
WriteMakefile(
    AUTHOR       => 'Alex Hodgkins',
    ABSTRACT     => 'XS wrapper around the htslib version of tabix',
    NAME         => 'Tabix',
    VERSION_FROM => 'Tabix.pm',
    LIBS         => ['-L/software/congenica/packages/htslib-1.2.1 -lhts -lz'],
    DEFINE       => '-I /software/congenica/packages/htslib-1.2.1/htslib -D_FILE_OFFSET_BITS=64 -D_USE_KNETFILE',
    INC          => '-I.',
);
