use v6;
unit class Sustenance::Utils;

# hash {{{

# hash C<Dateish> types by hand because raku doesn't do this for us
method hash(Dateish:D $dateish --> Hash:D)
{
    my %hash = hash($dateish);
}

proto sub hash(|)
{*}

multi sub hash(DateTime:D $date-time --> Hash:D)
{
    my (UInt:D $year,
        UInt:D $month,
        UInt:D $day) = $date-time.year,
                        $date-time.month,
                        $date-time.day;
    my (UInt:D $hour,
        UInt:D $minute,
        Rat:D $second) = $date-time.hour,
                            $date-time.minute,
                            $date-time.second;
    my %hash =
        :$year,
        :$month,
        :$day,
        :$hour,
        :$minute,
        :$second;
}

multi sub hash(Date:D $date --> Hash:D)
{
    my (UInt:D $year,
        UInt:D $month,
        UInt:D $day) = $date.year,
                        $date.month,
                        $date.day;
    my %hash =
        :$year,
        :$month,
        :$day;
}

# end hash }}}
# multiply {{{

# --- Fiber {{{

multi method multiply(Fiber:D $fiber, Numeric:D $num --> Fiber:D)
{
    my Fiber:D $multiply = multiply($fiber, $num);
}

multi sub multiply(Fiber:D $fiber, Numeric:D $num --> Fiber:D)
{
    my Gram:D $total = $fiber.total * $num;
    my Fraction:D $percent-insoluble = $fiber.percent-insoluble;
    my Fiber $multiply .= new(:$total, :$percent-insoluble);
}

multi sub infix:<*>(Fiber:D $fiber, Numeric:D $num --> Fiber:D) is export
{
    my Fiber:D $multiply = multiply($fiber, $num);
}

multi sub infix:<*>(Numeric:D $num, Fiber:D $fiber --> Fiber:D) is export
{
    my Fiber:D $multiply = multiply($fiber, $num);
}

# --- end Fiber }}}
# --- Carbohydrates {{{

multi method multiply(Carbohydrates:D $carbohydrates, Numeric:D $num --> Carbohydrates:D)
{
    my Carbohydrates:D $multiply = multiply($carbohydrates, $num);
}

multi sub multiply(Carbohydrates:D $carbohydrates, Numeric:D $num --> Carbohydrates:D)
{
    my Gram:D $total = $carbohydrates.total * $num;
    my Fiber:D $fiber = multiply($carbohydrates.fiber, $num);
    my Carbohydrates $multiply .= new(:$total, :$fiber);
}

multi sub infix:<*>(Carbohydrates:D $carbohydrates, Numeric:D $num --> Carbohydrates:D) is export
{
    my Carbohydrates:D $multiply = multiply($carbohydrates, $num);
}

multi sub infix:<*>(Numeric:D $num, Carbohydrates:D $carbohydrates --> Carbohydrates:D) is export
{
    my Carbohydrates:D $multiply = multiply($carbohydrates, $num);
}

# --- end Carbohydrates }}}
# --- Food {{{

# yield C<Portionʹ>, because C<Food> remains constant
multi method multiply(Food:D $food, Numeric:D $num --> Portionʹ:D)
{
    my Portionʹ:D $multiply = multiply($food, $num);
}

multi sub multiply(Food:D $food, Numeric:D $num --> Portionʹ:D)
{
    my FoodName:D $name = $food.name;
    my Serving:D $servings = $num;
    my Macros:D $macros = do {
        my Gram:D $protein = $food.protein * $num;
        my Carbohydrates:D $carbohydrates = multiply($food.carbohydrates, $num);
        my Gram:D $fat = $food.fat * $num;
        my Gram:D $alcohol = $food.alcohol * $num;
        Macros.new(:$protein, :$carbohydrates, :$fat, :$alcohol);
    };
    my Portionʹ $multiply .= new(:food($name), :$servings, :$macros);
}

multi sub infix:<*>(Food:D $food, Numeric:D $num --> Portionʹ:D) is export
{
    my Portionʹ:D $multiply = multiply($food, $num);
}

multi sub infix:<*>(Numeric:D $num, Food:D $food --> Portionʹ:D) is export
{
    my Portionʹ:D $multiply = multiply($food, $num);
}

# --- end Food }}}

# end multiply }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0 nowrap:
