use v6;
use lib 'lib';
use lib 't/lib';
use Sustenance;
use Sustenance::Parser::ParseTree;
use Test;
use TestSustenance;

plan(3);

my Str:D $file = 't/data/sustenance.toml';
my Sustenance $sustenance .= new(:$file);

subtest({
    my Pantry:D $pantry = %TestSustenance::data<pantry>;
    my Meal:D @meal = %TestSustenance::data<meal>.Array;
    my Sustenance $sustenance-expected .= new(:$pantry, :@meal);
    is-deeply(
        $sustenance,
        $sustenance-expected,
        '$sustenance eqv $sustenance-expected'
    );
});

subtest({
    my %macros-on-date = do {
        my Date $date .= new('2019-11-19');
        $sustenance.gen-macros($date);
    };
    my %totals-on-date = %macros-on-date<totals>;
    my %totals-on-date-expected =
        :alcohol(0.0),
        :calories(772.85),
        :carbohydrates({
            :net(114.0),
            :total(129.0)
        }),
        :fat(15.45),
        :fiber({
            :total(15.0),
            :insoluble(6.9),
            :soluble(8.1)
        }),
        :protein(40.4);
    is-deeply(
        %totals-on-date,
        %totals-on-date-expected,
        '%totals-on-date eqv %totals-on-date-expected'
    );
});

subtest({
    my %macros-in-date-range = do {
        my Date $d1 .= new('2019-11-01');
        my Date $d2 .= new('2019-11-19');
        $sustenance.gen-macros($d1, $d2);
    }
    my %totals-in-date-range = %macros-in-date-range<totals>;
    my %totals-in-date-range-expected =
        :alcohol(0.0),
        :calories(772.85),
        :carbohydrates({
            :net(114.0),
            :total(129.0)
        }),
        :fat(15.45),
        :fiber({
            :total(15.0),
            :insoluble(6.9),
            :soluble(8.1)
        }),
        :protein(40.4);
    is-deeply(
        %totals-in-date-range,
        %totals-in-date-range-expected,
        '%totals-in-date-range eqv %totals-in-date-range-expected'
    );
});

# vim: set filetype=raku foldmethod=marker foldlevel=0:
