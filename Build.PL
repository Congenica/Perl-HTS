use Module::Build;

use feature qw( say );
use strict;
use warnings;

my ( $hts_include, $hts_lib ) = find_hts();

say "Include dir $hts_include, hts lib is $hts_lib";

my $build = Module::Build->new(
    module_name          => 'Bio::HTS',
    dist_version_from    => 'lib/Bio/HTS.pm',
    dist_author          => 'Alex Hodgkins',
    dist_abstract        => 'Perl interface to htslib. Currently only tabix is supported',
    license              => 'idk',
    include_dirs         => [$hts_include],
    extra_linker_flags   => ["-L$hts_lib", '-lhts', '-lz'],
    extra_compiler_flags => [
        # must match DFLAGS in Samtools Makefile
        '-D_FILE_OFFSET_BITS=64', 
        # allow everything to work on files from the internet
        '-D_USE_KNETFILE',
    ],
    requires             => {
        'perl'                => '5.008',
    },
    verbose              => 1,
);

$build->create_build_script;

sub find_hts {
    my $include = "/software/congenica/packages/htslib-1.2.1/htslib"; #header files
    my $lib = "/software/congenica/packages/htslib-1.2.1"; #where htslib.so is
    return $include, $lib;
}
