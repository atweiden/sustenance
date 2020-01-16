use v6;
use Sustenance::Parser;
use Sustenance::Parser::ParseTree;
use Sustenance::Types;
use Sustenance::Utils;
use X::Sustenance;
unit class Sustenance;

# class attributes {{{

has Pantry:D $!pantry is required;
has Meal:D @!meal is required;

# --- accessor {{{

method pantry(::?CLASS:D:) { $!pantry }
method meal(::?CLASS:D:) { @!meal }

# --- end accessor }}}

# end class attributes }}}

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

multi method gen-macros(
    ::?CLASS:D:
    Date:D $d1,
    Date:D $d2
    --> TotalMacros:D
)
{
    my Range:D $date-range = $d1 .. $d2;
    my Mealʹ:D @mealʹ =
        gen-macros($.pantry, @.meal)
            .grep({ .date ~~ $date-range });
    my TotalMacros:D $macros = gen-macros(:@mealʹ);
}

multi method gen-macros(
    ::?CLASS:D:
    Date:D $d1,
    Date:D $d2,
    Time:D $t1,
    Time:D $t2
    --> TotalMacros:D
)
{
    my Range:D $date-range = $d1 .. $d2;
    my Mealʹ:D @mealʹ =
        gen-macros($.pantry, @.meal)
            .grep({ .date ~~ $date-range })
            .grep({ in-time-range(.time, $t1, $t2) });
    my TotalMacros:D $macros = gen-macros(:@mealʹ);
}

multi method gen-macros(
    ::?CLASS:D:
    Date:D $date,
    Time:D $t1,
    Time:D $t2
    --> TotalMacros:D
)
{
    my UInt:D ($year,
               $month,
               $day) = $date.year,
                       $date.month,
                       $date.day;
    my %date =
        :$year,
        :$month,
        :$day;
    my DateTime $dt1 .= new(|%date, |$t1.hash);
    my DateTime $dt2 .= new(|%date, |$t2.hash);
    my Range:D $date-time-range = $dt1 .. $dt2;
    my Mealʹ:D @mealʹ =
        gen-macros($.pantry, @.meal)
            .grep({ .date-time ~~ $date-time-range });
    my TotalMacros:D $macros = gen-macros(:@mealʹ);
}

multi method gen-macros(
    ::?CLASS:D:
    Date:D $date,
    Time:D $time
    --> TotalMacros:D
)
{
    my Mealʹ:D @mealʹ =
        gen-macros($.pantry, @.meal)
            .grep({ .date eqv $date })
            .grep({ .time eqv $time });
    my TotalMacros:D $macros = gen-macros(:@mealʹ);
}

multi method gen-macros(
    ::?CLASS:D:
    Date:D $date
    --> TotalMacros:D
)
{
    my Mealʹ:D @mealʹ =
        gen-macros($.pantry, @.meal)
            .grep({ .date eqv $date });
    my TotalMacros:D $macros = gen-macros(:@mealʹ);
}

# generate macros for the current date by default
multi method gen-macros(
    ::?CLASS:D:
    --> TotalMacros:D
)
{
    my Mealʹ:D @mealʹ =
        gen-macros($.pantry, @.meal)
            .grep({ .date eqv DateTime.now.Date });
    my TotalMacros:D $macros = gen-macros(:@mealʹ);
}

multi sub gen-macros(Pantry:D $pantry, Meal:D @meal --> Array[Mealʹ:D])
{
    my Mealʹ:D @mealʹ =
        @meal.map(-> Meal:D $meal {
            my Date:D $date = $meal.date;
            my Time:D $time = $meal.time;
            my DateTime:D $date-time = $meal.date-time;
            my Portion:D @portion = $meal.portion;
            my Portionʹ:D @portionʹ = gen-macros($pantry, @portion);
            my Mealʹ $mealʹ .= new(
                :$date,
                :$time,
                :$date-time,
                :@portionʹ
            );
        });
}

multi sub gen-macros(Pantry:D $pantry, Portion:D @portion --> Array[Portionʹ:D])
{
    my Portionʹ:D @portionʹ =
        @portion.map(-> Portion:D $portion {
            my FoodName:D $name = $portion.food;
            my Serving:D $servings = $portion.servings;
            my Food:D $food =
                $pantry.food.first({ .name eq $name })
                    // die(X::Sustenance::FoodMissing.new(:$name));
            my Portionʹ:D $portionʹ = $food * $servings;
        });
}

multi sub gen-macros(Mealʹ:D :@mealʹ! where .so --> TotalMacros:D)
{
    my Mealʹʹ:D @mealʹʹ =
        @mealʹ.map(-> $mealʹ {
            my Date:D $date = $mealʹ.date;
            my Time:D $time = $mealʹ.time;
            my DateTime:D $date-time = $mealʹ.date-time;
            my Portionʹ:D @portionʹ = $mealʹ.portionʹ;
            my Macros:D $macros = gen-macros(:@portionʹ);
            my Mealʹʹ $mealʹʹ .= new(
                :$date,
                :$time,
                :$date-time,
                :@portionʹ,
                :$macros
            );
        });
    my Macros:D $macros = gen-macros(:@mealʹʹ);
    my TotalMacros $total-macros .= new(
        :@mealʹʹ,
        :$macros
    );
}

multi sub gen-macros(Mealʹ:D :mealʹ(@)! --> Nil)
{
    die(X::Sustenance::MealMissing.new);
}

multi sub gen-macros(Portionʹ:D :@portionʹ! --> Macros:D)
{
    my Macros:D $macros = gen-macros-summed(@portionʹ);
}

multi sub gen-macros(Mealʹʹ:D :@mealʹʹ! --> Macros:D)
{
    my Macros:D $macros = gen-macros-summed(@mealʹʹ);
}

# accepts array of C<Macros>-containing raku containers
# sums C<Macros> therein
# instantiates new C<Macros> instance from summed C<Macros>
sub gen-macros-summed(@source --> Macros:D)
{
    my (Gram:D $protein,
        Gram:D $carbohydrates-total,
        Gram:D $fiber-total,
        Gram:D $fiber-insoluble,
        Gram:D $fat,
        Gram:D $alcohol) = 0.0;
    @source.map(-> $source {
        $protein += $source.macros.protein;
        $carbohydrates-total += $source.macros.carbohydrates.total;
        $fiber-total += $source.macros.carbohydrates.fiber.total;
        $fiber-insoluble += $source.macros.carbohydrates.fiber.insoluble;
        $fat += $source.macros.fat;
        $alcohol += $source.macros.alcohol;
    });
    my Fiber:D $fiber = do {
        # could also take weighted average of C<.percent-insoluble>
        # but this seems simpler
        my Fraction:D $percent-insoluble = $fiber-insoluble / $fiber-total;
        Fiber.new([$fiber-total, $percent-insoluble]);
    };
    my Carbohydrates $carbohydrates .= new(
        :total($carbohydrates-total),
        :$fiber
    );
    my Macros $macros .= new(
        :$protein,
        :$carbohydrates,
        :$fat,
        :$alcohol
    );
}

# end method gen-macros }}}
# method ls {{{

multi method ls(
    ::?CLASS:D:
    Bool:D :foods($)! where .so,
    Bool:D :meals($)! where .so
    --> Hash:D
)
{
    my Hash:D @food = $.pantry.food.map({ .hash });
    my Hash:D @meal = @.meal.map({ .hash });
    my %ls =
        :@food,
        :@meal;
}

multi method ls(
    ::?CLASS:D:
    Bool:D :foods($)! where .so
    --> Hash:D
)
{
    my Hash:D @food = $.pantry.food.map({ .hash });
    my %ls = :@food;
}

multi method ls(
    ::?CLASS:D:
    Bool:D :meals($)! where .so
    --> Hash:D
)
{
    my Hash:D @meal = @.meal.map({ .hash });
    my %ls = :@meal;
}

multi method ls(
    ::?CLASS:D:
    --> Hash:D
)
{
    my Hash:D @food = $.pantry.food.map({ .hash });
    my Hash:D @meal = @.meal.map({ .hash });
    my %ls =
        :@food,
        :@meal;
}

# end method ls }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0 nowrap:
