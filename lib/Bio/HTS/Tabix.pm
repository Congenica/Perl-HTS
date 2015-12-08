package Bio::HTS::Tabix;

use feature qw( say );
use Mouse;

use Bio::HTS; #load the XS
use Bio::HTS::File qw(hts_open hts_close);
use Bio::HTS::Tabix::Iterator;

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
    my ( $chr, $start, $end ) = $region =~ /([^:]):(\d+)(?:-(\d+))?/;
    unless ( defined $chr and defined $start ) {
        die "You must specify a region in the format chr:start or chr:start-end";
    }

    if ( defined $end ) {
        die "End in $region is less than the start" if $end < $start;
    }
    else {
        say STDERR "Note: You have not specified an end, which actually means chr:start-end_of_chromosome";
    }

    my $iter = tbx_query( $self->_tabix_index, $region );

    unless ( $iter ) {
        die "Unable to get iterator for region $region -- is your end smaller than your start?";
    }

    return Bio::HTS::Tabix::Iterator->new( _tabix_iter => $iter, _htsfile => $self->_htsfile, _tabix_index => $self->_tabix_index );
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

=head1 NAME

Bio::HTS::Tabix - Object oriented access to the underlying tbx C methods

=head1 SYNOPSIS

    use feature qw( say );
    use Bio::HTS::Tabix;

    my $tabix = Bio::HTS::Tabix->new( filename => "gerp_plus_plus_31July2014.gz" );

    say $tabix->header;
    my $iter = $tabix->query("1:4000005-4000009");

    while ( my $n = $iter->next ) {
        say $n;
    }

=head1 DESCRIPTION

A high level object oriented interface to the htslib tabix (tbx.h) api. Currently it only supports
retrieving regions from a tabixed file, because that's all I needed it for.

=head2 Methods

=over 12

=item C<header>

Returns all the header lines as a single scalar from the tabixed file

=item C<query>

Takes a single region like: '1:4000005-4000009' or '12:5000000'
Note: this works exactly the same way as the tabix executable,
so '12:5000000' actually means get all results from position 5,000,000
up to the very end of the chromosome. To get results only at position
5,000,000 you should do '12:5000000-5000001'

Returns a L<Bio::HTS::Tabix::Iterator> for the specified region

=item C<seqnames>

Returns an array ref of chromosomes that are in the indexed file

=back

=head1 COPYRIGHT

Copyright 2015 Congenica Ltd.

=head1 AUTHOR

Alex Hodgkins

=cut
