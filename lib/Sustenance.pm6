use v6;
use Sustenance::Parser::ParseTree;
use Sustenance::Parser;
use Sustenance::Types;
unit class Sustenance;

has Pantry:D $.pantry is required;
has Meal:D @.meal is required;

# submethod BUILD {{{

submethod BUILD(
    Pantry:D :$!pantry!,
    Meal:D :@!meal!
    --> Nil
)
{*}

# end submethod BUILD }}}
# method new {{{

multi method new(
    Str:D :$file! where .so
    --> Sustenance:D
)
{
    my %sustenance = from-sustenance(:$file);
    self.bless(|%sustenance);
}

multi method new(
    Str:D $content where .so
    --> Sustenance:D
)
{
    my %sustenance = from-sustenance($content);
    self.bless(|%sustenance);
}

# end method new }}}

# method gen-macros {{{

multi method gen-macros(::?CLASS:D: Date:D $d1, Date:D $d2 --> Array[Hash:D])
{
    my Range:D $date-range = $d1 .. $d2;
    my Hash:D @meal =
        gen-macros($.pantry, @.meal).grep({ $date-range.in-range(.<date>) });
    my Hash:D @macros = gen-macros(:@meal);
}

multi method gen-macros(::?CLASS:D: Date:D $date --> Array[Hash:D])
{
    my Hash:D @meal =
        gen-macros($.pantry, @.meal).grep({ .<date> eqv $date });
    my Hash:D @macros = gen-macros(:@meal);
}

multi method gen-macros(::?CLASS:D: --> Array[Hash:D])
{
    my Hash:D @meal = gen-macros($.pantry, @.meal);
    my Hash:D @macros = gen-macros(:@meal);
}

multi sub gen-macros(Pantry:D $pantry, Meal:D @m --> Array[Hash:D])
{
    my Hash:D @meal =
        @m.map(-> Meal:D $meal {
            my Date:D $date = $meal.date;
            my Time:D $time = $meal.time;
            my Portion:D @p = $meal.portion;
            my Hash:D @portion = gen-macros(@p, $pantry);
            my %meal = :$date, :$time, :@portion;
        });
}

multi sub gen-macros(Portion:D @p, Pantry:D $pantry --> Array[Hash:D])
{
    my Hash:D @portion =
        @p.map(-> Portion:D $portion {
            my FoodName:D $name = $portion.food;
            my Servings:D $servings = $portion.servings;
            my Food:D $food = $pantry.food.first({ .name eq $name });
            my Calories:D $calories = $food.calories * $servings;
            my Protein:D $protein = $food.protein * $servings;
            my Carbohydrates:D $carbohydrates = $food.carbohydrates * $servings;
            my Fat:D $fat = $food.fat * $servings;
            my %macros = :$calories, :$protein, :$carbohydrates, :$fat;
            my %portion = :food($name), :$servings, :%macros;
        });
}

multi sub gen-macros(Hash:D :@meal! --> Array[Hash:D])
{
    my Hash:D @macros =
        @meal.map(-> %meal {
            my Hash:D @portion = %meal<portion>.Array;
            my (Calories:D $calories,
                Protein:D $protein,
                Carbohydrates:D $carbohydrates,
                Fat:D $fat) = gen-macros(:@portion);
            my %totals = :$calories, :$protein, :$carbohydrates, :$fat;
            my %macros = :%meal, :%totals;
        });
}

multi sub gen-macros(Hash:D :@portion! --> Array:D)
{
    my (Calories:D $calories,
        Protein:D $protein,
        Carbohydrates:D $carbohydrates,
        Fat:D $fat) = 0.0;
    @portion.map(-> %portion {
        $calories += %portion<macros><calories>;
        $protein += %portion<macros><protein>;
        $carbohydrates += %portion<macros><carbohydrates>;
        $fat += %portion<macros><fat>;
    });
    my @macros = $calories, $protein, $carbohydrates, $fat;
}

# end method gen-macros }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
