package Tabix;

use feature qw( say );
use Mouse;

use TabixIterator;
use HTSFile qw(hts_open hts_close);

our $VERSION = '0.0.1';

require XSLoader;
XSLoader::load('Tabix', $VERSION);

has 'filename' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

#pointer to a htsFile
has '_htsfile' => (
    is        => 'ro',
    isa       => 'htsFilePtr',
    builder   => '_build__htsfile',
    predicate => '_has_htsfile',
    lazy      => 1,
);

sub _build__htsfile {
    my $self = shift;

    die "Filename " . $self->filename . " does not exist" unless -e $self->filename;

    return hts_open($self->filename);
}

has '_tabix_index' => (
    is        => 'ro',
    isa       => 'tbx_tPtr',
    builder   => '_build__tabix_index',
    predicate => '_has_tabix_index',
    lazy      => 1,
);

sub _build__tabix_index {
    my $self = shift;

    #make sure the htsfile is instantiated
    $self->_htsfile;

    my $index = tbx_open($self->filename);

    die "Couldn't find index for file " . $self->filename unless $index;

    return $index;
}

has 'header' => (
    is      => 'ro',
    isa     => 'Str',
    builder => '_build_header',
    lazy    => 1,
);

sub _build_header {
    my $self = shift;

    #returns an arrayref
    my $header = tbx_header($self->_htsfile, $self->_tabix_index);

    return unless $header;

    return join "", @{ $header };
}

sub BUILD {
    my ( $self ) = @_;

    #fetch the header of the file, which will in turn open the tabix index and the file
    $self->header;

    return;
}

sub query {
    my ( $self, $region ) = @_;

    die "Please provide a region" unless defined $region;
    die "Region must be in the format chr:start or chr:start-end" unless $region =~ /[^:]:\d+(?:-(\d+))?/;

    my $iter = tbx_query( $self->_tabix_index, $region );
    return TabixIterator->new( _tabix_iter => $iter, _htsfile => $self->_htsfile, _tabix_index => $self->_tabix_index );
}


sub seqnames {
    my $self = shift;
    return tbx_seqnames($self->_tabix_index);
}

#free up memory allocated in XS code
sub DEMOLISH {
    my $self = shift;

    if ( $self->_has_htsfile ) {
        hts_close($self->_htsfile);
    }

    if ( $self->_has_tabix_index ) {
        tbx_close($self->_tabix_index);
    }
}

1;

__END__
