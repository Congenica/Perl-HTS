package Bio::HTS;

our $VERSION = 0.0.1;

use Try::Tiny;

require XSLoader;
try {
    XSLoader::load('Bio::HTS', $VERSION);
}
catch {
    die "Error loading XS components for Bio::HTS (have you installed htslib? is it in your LD_LIBRARY_PATH?):\n$_";
};

1;

__END__

=head1 NAME

Bio::HTS - XS module providing an interface to htslib

=head1 DESCRIPTION

The beginnings of an XS wrapper around the many useful methods in htslib. All the other perl modules
use the old samtools or aren't on cpan.

So far only Tabix is supported.

Contributions welcome on github: L<http://www.github.com/congenica/perl_htslib>

=head2 Installation

To install you will need a compiled copy of htslib (I wrote the code against htslib1.2.1, so use that)

If you have done make install in htslib and htslib.so is installed system wide then I think it should just work.

If you want to link to a htslib installed somewhere else you will need to add the install directory to your LD_LIBRARY_PATH
environment variable BEFORE running cpanm -- the Build.PL script will search through all folders in LD_LIBRARY_PATH looking for libhts.so
and a htslib subfolder containing .h files. Any perl script you run that uses Bio::HTS will need htslib in LD_LIBRARY_PATH.

If it has installed but is not working, checking the linking of the .so file like so:

    ldd lib/arch/auto/Bio/HTS/HTS.so

    linux-vdso.so.1 =>  (0x00007fff34fff000)
    libhts.so.1     => not found
    libc.so.6       => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fe398205000)
    /lib64/ld-linux-x86-64.so.2 (0x00007fe3987e4000)

libhts.so.1 is listed as not found, so the module will die when it is loaded. It is fixed by setting the LD_LIBRARY_PATH:

    export LD_LIBRARY_PATH=~/htslib-1.2.1

    ldd lib/arch/auto/Bio/HTS/HTS.so

    linux-vdso.so.1 =>  (0x00007fff34fff000)
    libhts.so.1 => /users/alex/htslib-1.2.1/libhts.so.1 (0x00007ff666ea6000)
    ...

=head1 COPYRIGHT

Copyright 2015 Congenica Ltd.

=head1 AUTHOR

Alex Hodgkins

=cut
