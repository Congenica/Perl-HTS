use Test::Most tests => 9, 'die';

use FindBin qw( $Bin );

use_ok 'Bio::HTS::Tabix';

my $test_file = $Bin . '/data/test.tsv.gz';

dies_ok { Bio::HTS::Tabix->new( filename => $test_file . "efleaf" ); } 'missing file dies';
dies_ok { Bio::HTS::Tabix->new( filename => $Bin . '/data/no_index.tsv.gz' ); } 'file with no tabix index dies';

isa_ok my $tbx = Bio::HTS::Tabix->new( filename => $test_file ), "Bio::HTS::Tabix";
ok my $iter = $tbx->query("12:8000000-8000008"), "can query a region";
isa $iter, "Bio::HTS::Tabix::Iterator";

#make sure we can call next
ok my $row = $iter->next, 'can get a value from the iterator';
is $row, "12\t8000000\t8000000\t-2.94", 'row value is correct';

my $num_rows = 0;
++$num_rows while $iter->next;
is $num_rows, 7, "correct number of values come back from the iterator";

#check seqnames
isa my $seqnames = $tbx->seqnames, 'ARRAY';
is_deeply $seqnames, [1, 12, 'X'], 'seqnames are correct';

done_testing;
