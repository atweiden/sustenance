use v6;
use lib 'lib';
use lib 't/lib';
use Sustenance;
use Sustenance::Parser::ParseTree;
use Sustenance::Types;
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
    my TotalMacros:D $total-macros = do {
        my Date $date .= new('2019-11-19');
        $sustenance.gen-macros($date);
    };
    my Macros:D $macros-on-date = $total-macros.macros;
    # here as a guide and for checking output
    my %macros-on-date-expected =
        :alcohol(0.0),
        :calories(772.85),
        :carbohydrates({
            :fiber({
                :total(15.0),
                :insoluble(6.9),
                :soluble(8.1)
            }),
            :net(114.0),
            :total(129.0)
        }),
        :fat(15.45),
        :protein(40.4);
    my Macros:D $macros-on-date-expected = do {
        my Gram:D $protein = %macros-on-date-expected<protein>;
        my Fiber $fiber .= new(
            [%macros-on-date-expected<carbohydrates><fiber><total>,
             %macros-on-date-expected<carbohydrates><fiber><insoluble> /
             %macros-on-date-expected<carbohydrates><fiber><total>]);
        my Carbohydrates $carbohydrates .= new(
            :total(%macros-on-date-expected<carbohydrates><total>),
            :$fiber
        );
        my Gram:D $fat = %macros-on-date-expected<fat>;
        my Gram:D $alcohol = %macros-on-date-expected<alcohol>;
        Macros.new(:$protein, :$carbohydrates, :$fat, :$alcohol);
    };
    is-deeply(
        $macros-on-date,
        $macros-on-date-expected,
        '$macros-on-date eqv $macros-on-date-expected'
    );
    is-deeply(
        $macros-on-date.hash,
        $macros-on-date-expected.hash,
        '$macros-on-date.hash eqv $macros-on-date-expected.hash'
    );
    is-deeply(
        $macros-on-date.hash,
        %macros-on-date-expected,
        '$macros-on-date.hash eqv %macros-on-date-expected'
    );
    is-deeply(
        $macros-on-date.calories,
        %macros-on-date-expected<calories>,
        '$macros-on-date.calories eqv 772.85'
    );
    is-deeply(
        $macros-on-date-expected.calories,
        %macros-on-date-expected<calories>,
        '$macros-on-date-expected.calories eqv 772.85'
    );
    is-deeply(
        $macros-on-date.protein,
        %macros-on-date-expected<protein>,
        '$macros-on-date.protein eqv 40.4'
    );
    is-deeply(
        $macros-on-date-expected.protein,
        %macros-on-date-expected<protein>,
        '$macros-on-date-expected.protein eqv 40.4'
    );
    is-deeply(
        $macros-on-date.carbohydrates.fiber.total,
        %macros-on-date-expected<carbohydrates><fiber><total>,
        '$macros-on-date.carbohydrates.fiber.total eqv 15.0'
    );
    is-deeply(
        $macros-on-date-expected.carbohydrates.fiber.total,
        %macros-on-date-expected<carbohydrates><fiber><total>,
        '$macros-on-date-expected.carbohydrates.fiber.total eqv 15.0'
    );
    is-deeply(
        $macros-on-date.carbohydrates.fiber.insoluble,
        %macros-on-date-expected<carbohydrates><fiber><insoluble>,
        '$macros-on-date.carbohydrates.fiber.insoluble eqv 6.9'
    );
    is-deeply(
        $macros-on-date-expected.carbohydrates.fiber.insoluble,
        %macros-on-date-expected<carbohydrates><fiber><insoluble>,
        '$macros-on-date-expected.carbohydrates.fiber.insoluble eqv 6.9'
    );
    is-deeply(
        $macros-on-date.carbohydrates.fiber.soluble,
        %macros-on-date-expected<carbohydrates><fiber><soluble>,
        '$macros-on-date.carbohydrates.fiber.soluble eqv 8.1'
    );
    is-deeply(
        $macros-on-date-expected.carbohydrates.fiber.soluble,
        %macros-on-date-expected<carbohydrates><fiber><soluble>,
        '$macros-on-date-expected.carbohydrates.fiber.soluble eqv 8.1'
    );
    is-deeply(
        $macros-on-date.carbohydrates.net,
        %macros-on-date-expected<carbohydrates><net>,
        '$macros-on-date.carbohydrates.net eqv 114.0'
    );
    is-deeply(
        $macros-on-date-expected.carbohydrates.net,
        %macros-on-date-expected<carbohydrates><net>,
        '$macros-on-date-expected.carbohydrates.net eqv 114.0'
    );
    is-deeply(
        $macros-on-date.carbohydrates.total,
        %macros-on-date-expected<carbohydrates><total>,
        '$macros-on-date.carbohydrates.total eqv 129.0'
    );
    is-deeply(
        $macros-on-date-expected.carbohydrates.total,
        %macros-on-date-expected<carbohydrates><total>,
        '$macros-on-date-expected.carbohydrates.total eqv 129.0'
    );
    is-deeply(
        $macros-on-date.fat,
        %macros-on-date-expected<fat>,
        '$macros-on-date.fat eqv 15.45'
    );
    is-deeply(
        $macros-on-date-expected.fat,
        %macros-on-date-expected<fat>,
        '$macros-on-date-expected.fat eqv 15.45'
    );
    is-deeply(
        $macros-on-date.alcohol,
        %macros-on-date-expected<alcohol>,
        '$macros-on-date.alcohol eqv 0.0'
    );
    is-deeply(
        $macros-on-date-expected.alcohol,
        %macros-on-date-expected<alcohol>,
        '$macros-on-date-expected.alcohol eqv 0.0'
    );
});

subtest({
    my TotalMacros:D $total-macros = do {
        my Date $d1 .= new('2019-11-01');
        my Date $d2 .= new('2019-11-19');
        $sustenance.gen-macros($d1, $d2);
    }
    my Macros:D $macros-in-date-range = $total-macros.macros;
    # here as a guide and for checking output
    my %macros-in-date-range-expected =
        :alcohol(0.0),
        :calories(772.85),
        :carbohydrates({
            :fiber({
                :total(15.0),
                :insoluble(6.9),
                :soluble(8.1)
            }),
            :net(114.0),
            :total(129.0)
        }),
        :fat(15.45),
        :protein(40.4);
    my Macros:D $macros-in-date-range-expected = do {
        my Gram:D $protein = %macros-in-date-range-expected<protein>;
        my Fiber $fiber .= new(
            [%macros-in-date-range-expected<carbohydrates><fiber><total>,
             %macros-in-date-range-expected<carbohydrates><fiber><insoluble> /
             %macros-in-date-range-expected<carbohydrates><fiber><total>]);
        my Carbohydrates $carbohydrates .= new(
            :total(%macros-in-date-range-expected<carbohydrates><total>),
            :$fiber
        );
        my Gram:D $fat = %macros-in-date-range-expected<fat>;
        my Gram:D $alcohol = %macros-in-date-range-expected<alcohol>;
        Macros.new(:$protein, :$carbohydrates, :$fat, :$alcohol);
    };
    is-deeply(
        $macros-in-date-range,
        $macros-in-date-range-expected,
        '$macros-in-date-range eqv $macros-in-date-range-expected'
    );
    is-deeply(
        $macros-in-date-range.hash,
        $macros-in-date-range-expected.hash,
        '$macros-in-date-range.hash eqv $macros-in-date-range-expected.hash'
    );
    is-deeply(
        $macros-in-date-range.hash,
        %macros-in-date-range-expected,
        '$macros-in-date-range.hash eqv %macros-in-date-range-expected'
    );
    is-deeply(
        $macros-in-date-range.calories,
        772.85,
        '$macros-in-date-range.calories eqv 772.85'
    );
    is-deeply(
        $macros-in-date-range-expected.calories,
        772.85,
        '$macros-in-date-range-expected.calories eqv 772.85'
    );
    is-deeply(
        $macros-in-date-range.protein,
        40.4,
        '$macros-in-date-range.protein eqv 40.4'
    );
    is-deeply(
        $macros-in-date-range-expected.protein,
        40.4,
        '$macros-in-date-range-expected.protein eqv 40.4'
    );
    is-deeply(
        $macros-in-date-range.carbohydrates.fiber.total,
        15.0,
        '$macros-in-date-range.carbohydrates.fiber.total eqv 15.0'
    );
    is-deeply(
        $macros-in-date-range-expected.carbohydrates.fiber.total,
        15.0,
        '$macros-in-date-range-expected.carbohydrates.fiber.total eqv 15.0'
    );
    is-deeply(
        $macros-in-date-range.carbohydrates.fiber.insoluble,
        6.9,
        '$macros-in-date-range.carbohydrates.fiber.insoluble eqv 6.9'
    );
    is-deeply(
        $macros-in-date-range-expected.carbohydrates.fiber.insoluble,
        6.9,
        '$macros-in-date-range-expected.carbohydrates.fiber.insoluble eqv 6.9'
    );
    is-deeply(
        $macros-in-date-range.carbohydrates.fiber.soluble,
        8.1,
        '$macros-in-date-range.carbohydrates.fiber.soluble eqv 8.1'
    );
    is-deeply(
        $macros-in-date-range-expected.carbohydrates.fiber.soluble,
        8.1,
        '$macros-in-date-range-expected.carbohydrates.fiber.soluble eqv 8.1'
    );
    is-deeply(
        $macros-in-date-range.carbohydrates.net,
        114.0,
        '$macros-in-date-range.carbohydrates.net eqv 114.0'
    );
    is-deeply(
        $macros-in-date-range-expected.carbohydrates.net,
        114.0,
        '$macros-in-date-range-expected.carbohydrates.net eqv 114.0'
    );
    is-deeply(
        $macros-in-date-range.carbohydrates.total,
        129.0,
        '$macros-in-date-range.carbohydrates.total eqv 129.0'
    );
    is-deeply(
        $macros-in-date-range-expected.carbohydrates.total,
        129.0,
        '$macros-in-date-range-expected.carbohydrates.total eqv 129.0'
    );
    is-deeply(
        $macros-in-date-range.fat,
        15.45,
        '$macros-in-date-range.fat eqv 15.45'
    );
    is-deeply(
        $macros-in-date-range-expected.fat,
        15.45,
        '$macros-in-date-range-expected.fat eqv 15.45'
    );
    is-deeply(
        $macros-in-date-range.alcohol,
        0.0,
        '$macros-in-date-range.alcohol eqv 0.0'
    );
    is-deeply(
        $macros-in-date-range-expected.alcohol,
        0.0,
        '$macros-in-date-range-expected.alcohol eqv 0.0'
    );
});

# vim: set filetype=raku foldmethod=marker foldlevel=0:
