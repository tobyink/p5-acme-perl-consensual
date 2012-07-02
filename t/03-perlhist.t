use Test::More tests => 2;
use Acme::Perl::Consensual;

ok(Acme::Perl::Consensual->new->age_of_perl('5.16')   < 16);
ok(Acme::Perl::Consensual->new->age_of_perl('2.000')  > 20);
