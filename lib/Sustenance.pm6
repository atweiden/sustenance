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

method gen-macros(::?CLASS:D: --> Array[Hash:D])
{
    my Hash:D @meal =
        @.meal.map(-> Meal:D $meal {
            my Date:D $date = $meal.date;
            my Time:D $time = $meal.time;
            my Portion:D @p = $meal.portion;
            my Hash:D @portion =
                @p.map(-> Portion:D $portion {
                    my FoodName:D $name = $portion.food;
                    my Servings:D $servings = $portion.servings;
                    my Food:D $food = $.pantry.food.first({ .name eq $name });
                    my Calories:D $calories = $food.calories * $servings;
                    my Protein:D $protein = $food.protein * $servings;
                    my Carbohydrates:D $carbohydrates =
                        $food.carbohydrates * $servings;
                    my Fat:D $fat = $food.fat * $servings;
                    my %macros = :$calories, :$protein, :$carbohydrates, :$fat;
                    my %portion = :food($name), :$servings, :%macros;
                });
            my %meal = :$date, :$time, :@portion;
        });
    my Hash:D @macros =
        @meal.map(-> %meal {
            my Calories:D $calories =
                [+] %meal<portion>.map(-> %portion { %portion<macros><calories> });
            my Protein:D $protein =
                [+] %meal<portion>.map(-> %portion { %portion<macros><protein> });
            my Carbohydrates:D $carbohydrates =
                [+] %meal<portion>.map(-> %portion { %portion<macros><carbohydrates> });
            my Fat:D $fat =
                [+] %meal<portion>.map(-> %portion { %portion<macros><fat> });
            my %totals = :$calories, :$protein, :$carbohydrates, :$fat;
            my %macro = :%meal, :%totals;
        });
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
