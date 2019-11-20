use v6;
use Sustenance::Parser::ParseTree;
unit module TestSustenance;

# --- $pantry {{{

my Pantry:D $pantry = do {
    my Food $agave-syrup .=
        new(
            :name<agave-syrup>,
            :serving-size('1 tbsp'),
            :protein(0.0),
            :carbs(13),
            :fiber([0.0, 1.0]),
            :fat(0.0)
        );
    my Food $allspice .=
        new(
            :name<allspice>,
            :serving-size('1 tbsp (6g)'),
            :protein(0.4),
            :carbs(4.3),
            :fiber(1.3),
            :fat(0.5)
        );
    my Food $almond .=
        new(
            :name<almond>,
            :serving-size('100g'),
            :protein(24.1),
            :carbs(19.1),
            :fiber([12.5, 0.552]),
            :fat(51.2)
        );
    my Food $banana .=
        new(
            :name<banana>,
            :serving-size('100g'),
            :protein(1.2),
            :carbs(20.1),
            :fiber([1.8, 0.56])
            :fat(0.4)
        );
    my Food $hemp-seed-protein-powder .=
        new(
            :name<hemp-seed-protein-powder>,
            :serving-size('4 tbsp'),
            :protein(20.0),
            :carbs(4.5),
            :fat(4.5)
        );
    my Food $quinoa .=
        new(
            :name<quinoa>,
            :serving-size('100g'),
            :protein(4.8),
            :carbs(22.9),
            :fiber([2.8, 0.0])
            :fat(2.4)
        );
    my Food $rolled-oats .=
        new(
            :name<rolled-oats>,
            :serving-size('100g'),
            :protein(13.6),
            :carbs(70.0),
            :fiber([10.0, 0.46])
            :fat(7.2)
        );
    my Food:D @food =
        $agave-syrup,
        $allspice,
        $almond,
        $banana,
        $hemp-seed-protein-powder,
        $quinoa,
        $rolled-oats;
    Pantry.new(:@food);
};

# --- end $pantry }}}
# --- @meal {{{

my Meal:D $meal-a = do {
    my Date $date .= new('2019-11-19');
    my %time = :hour(10), :minute(15), :second(0.0);
    my %portion-rolled-oats =
        :food<rolled-oats>,
        :servings(1.5);
    my %portion-agave-syrup =
        :food<agave-syrup>,
        :servings(1.5);
    my %portion-hemp-seed-protein-powder =
        :food<hemp-seed-protein-powder>,
        :servings(1.0);
    my Hash:D @portion =
        %portion-rolled-oats,
        %portion-agave-syrup,
        %portion-hemp-seed-protein-powder;
    Meal.new(:$date, :%time, :@portion);
};

my Meal:D $meal-b = do {
    my Date $date .= new('2019-11-19');
    my %time = :hour(17), :minute(5), :second(0.0);
    my %portion-almond =
        :food<almond>,
        :servings(0.5);
    my %portion-quinoa =
        :food<quinoa>,
        :servings(2.5);
    my %portion-allspice =
        :food<allspice>,
        :servings(1.0);
    my %portion-banana =
        :food<banana>,
        :servings(0.75);
    my Hash:D @portion =
        %portion-almond,
        %portion-quinoa,
        %portion-allspice,
        %portion-banana;
    Meal.new(:$date, :%time, :@portion);
};

my Meal:D @meal =
    $meal-a,
    $meal-b;

# --- end @meal }}}

our %data =
    :$pantry,
    :@meal;

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
