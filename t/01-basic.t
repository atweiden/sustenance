use v6;
use lib 'lib';
use Sustenance;
use Sustenance::Parser::ParseTree;
use Sustenance::Types;
use Test;

plan(1);

subtest({
    my Str:D $file = 't/data/sustenance.toml';
    my Sustenance $sustenance .= new(:$file);

    # --- $pantry {{{

    my Pantry:D $pantry = do {
        my Food $hemp-protein-powder .=
            new(
                :name<hemp-protein-powder>,
                :serving-size('4 tbspn'),
                :protein(20.0),
                :carbs(4.5),
                :fat(4.5)
            );
        my Food $oats .=
            new(
                :name<oats>,
                :serving-size('1 cup'),
                :protein(14.0),
                :carbs(58.0),
                :fat(6.0)
            );
        my Food $agave-syrup .=
            new(
                :name<agave-syrup>,
                :serving-size('2 tbspn'),
                :protein(0.0),
                :carbs(32.0),
                :fat(0.0)
            );
        my Food $dried-cranberries .=
            new(
                :name<dried-cranberries>,
                :serving-size('1 cup'),
                :protein(1.0),
                :carbs(32.0),
                :fat(0.0)
            );
        my Food $dates .=
            new(
                :name<dates>,
                :serving-size('12 pieces'),
                :protein(3.0),
                :carbs(80.0),
                :fat(0.5)
            );
        my Food $banana .=
            new(
                :name<banana>,
                :serving-size('1 medium (7-8" long)'),
                :protein(1.0),
                :carbs(27.0),
                :fat(0.4)
            );
        my Food $almonds .=
            new(
                :name<almonds>,
                :serving-size('1 oz'),
                :protein(6.0),
                :carbs(5.5),
                :fat(14.0)
            );
        my Food:D @food =
            $hemp-protein-powder,
            $oats,
            $agave-syrup,
            $dried-cranberries,
            $dates,
            $banana,
            $almonds;
        Pantry.new(:@food);
    };

    # --- end $pantry }}}
    # --- @meal {{{

    my Meal:D $meal = do {
        my Date $date .= new('2018-05-31');
        my %time = :hour(10), :minute(15), :second(0.0);
        my %portion-oats =
            :food<oats>,
            :servings(1.5);
        my %portion-agave-syrup =
            :food<agave-syrup>,
            :servings(1.5);
        my %portion-hemp-protein-powder =
            :food<hemp-protein-powder>,
            :servings(1.0);
        my Hash:D @portion =
            %portion-oats,
            %portion-agave-syrup,
            %portion-hemp-protein-powder;
        Meal.new(:$date, :%time, :@portion);
    };

    my Meal:D @meal = $meal;

    # --- end @meal }}}

    my Sustenance $sustenance-expected .= new(:$pantry, :@meal);
    is-deeply(
        $sustenance,
        $sustenance-expected,
        '$sustenance eqv $sustenance-expected'
    );

    my %macros-on-date = do {
        my Date $date .= new('2018-05-31');
        $sustenance.gen-macros($date);
    };
    my %totals-on-date = %macros-on-date<totals>;
    my %totals-on-date-expected =
        :alcohol(0.0),
        :calories(843.5),
        :carbohydrates(139.5),
        :fat(13.5),
        :protein(41.0);
    is-deeply(
        %totals-on-date,
        %totals-on-date-expected,
        '%totals-on-date eqv %totals-on-date-expected'
    );

    my %macros-in-date-range = do {
        my Date $d1 .= new('2018-05-30');
        my Date $d2 .= new('2018-06-01');
        $sustenance.gen-macros($d1, $d2);
    }
    my %totals-in-date-range = %macros-in-date-range<totals>;
    my %totals-in-date-range-expected =
        :alcohol(0.0),
        :calories(843.5),
        :carbohydrates(139.5),
        :fat(13.5),
        :protein(41.0);
    is-deeply(
        %totals-in-date-range,
        %totals-in-date-range-expected,
        '%totals-in-date-range eqv %totals-in-date-range-expected'
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
