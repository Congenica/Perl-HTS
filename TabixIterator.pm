package TabixIterator;

use Mouse;

require Tabix; #does this actually do anything?

#this class is just a wrapper around the tabix_iter_next method,
#all the attributes it needs come from the main Tabix method

#a hts_itr_t pointer which is returned from Tabix::query
has "_tabix_iter" => (
    is  => 'ro',
    isa => 'hts_itr_tPtr',
);

#an open htsFile pointer
has '_htsfile' => (
    is       => 'ro',
    isa      => 'htsFilePtr',
    required => 1,
);

has '_tabix_index' => (
    is       => 'ro',
    isa      => 'tbx_tPtr',
    required => 1,
);

sub next {
    my $self = shift;

    #this is an xs method
    return tbx_iter_next($self->_tabix_iter, $self->_htsfile, $self->_tabix_index);
}

sub DEMOLISH {
  my $self = shift;

  #xs method
  tbx_iter_free($self->_tabix_iter);
}

1;
__END__
