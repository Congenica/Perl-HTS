use Test::Most tests => 3, 'die';

use FindBin qw( $Bin );

use_ok 'Bio::HTS::VCF';

ok my $v = Bio::HTS::VCF->new( filename => $Bin . "/data/test.vcf.gz" );
is $v->num_variants, 9, 'correct number of variants identified in file';

