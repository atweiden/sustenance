use v6;
use Sustenance::Types;
use Sustenance::Utils;

# class Fiber {{{

class Fiber
{
    # total fiber, including soluble and insoluble sources
    has Gram:D $.total = 0.0;
    has Fraction:D $.percent-insoluble = 0.0;
    has Fraction:D $!percent-soluble = 1.0 - $!percent-insoluble;

    submethod BUILD(
        Numeric :$total,
        Numeric :$percent-insoluble
        --> Nil
    )
    {
        $!total = Rat($total) if $total;
        $!percent-insoluble = Rat($percent-insoluble) if $percent-insoluble;
    }


    proto method new(|)
    {*}

    multi method new(
        @ (Numeric:D $total where * >= 0,
           Numeric:D $percent-insoluble where 0 <= * <= 1)
        --> Fiber:D)
    {
        self.bless(:$total, :$percent-insoluble);
    }

    multi method new(
        Numeric:D $total where * >= 0
        --> Fiber:D
    )
    {
        self.bless(:$total);
    }

    multi method new(--> Fiber:D)
    {
        self.bless;
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash =
            :$.total,
            :$.insoluble,
            :$.soluble;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }

    method insoluble(::?CLASS:D: --> Gram:D)
    {
        my Gram:D $insoluble = $.total * $.percent-insoluble;
    }

    method soluble(::?CLASS:D: --> Gram:D)
    {
        my Gram:D $soluble = $.total * $!percent-soluble;
    }
}

# end class Fiber }}}
# class Carbohydrates {{{

class Carbohydrates
{
    # total carbohydrates, including all sources of fiber
    has Gram:D $.total is required;
    has Fiber:D $.fiber = Fiber.new;

    submethod BUILD(
        Numeric:D :$total!,
        Fiber :$fiber
        --> Nil
    )
    {
        $!total = Rat($total);
        $!fiber = $fiber if $fiber;
    }

    method new(
        *%opts (
            Numeric:D :total($)! where * >= 0,
            Fiber :fiber($)
        )
        --> Carbohydrates:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %fiber = $.fiber.hash;
        my %hash =
            :$.total,
            :$.net,
            :%fiber;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }

    # carbohydrates less all sources of fiber
    method net(::?CLASS:D: --> Gram:D)
    {
        my Gram:D $net = $.total - $.fiber.total;
    }
}

# end class Carbohydrates }}}
# role Macros {{{

role Macros
{
    has Gram:D $.protein is required;
    has Carbohydrates:D $.carbohydrates is required;
    has Gram:D $.fat is required;
    has Gram:D $.alcohol = 0.0;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %carbohydrates = $.carbohydrates.hash;
        my %hash =
            :$.calories,
            :$.protein,
            :%carbohydrates,
            :$.fat,
            :$.alcohol;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }

    method calories(::?CLASS:D: --> Kilocalorie:D)
    {
        # atwater system
        # 1 gram of protein is 4 kcal
        my Kilocalorie:D $kcal-per-g-protein = 4.0;
        # 1 gram of carbohydrates is 4 kcal
        my Kilocalorie:D $kcal-per-g-carbohydrates = 4.0;
        # 1 gram of soluble fiber is 2 kcal
        my Kilocalorie:D $kcal-per-g-fiber-soluble = 2.0;
        # 1 gram of insoluble fiber is 0 kcal
        my Kilocalorie:D $kcal-per-g-fiber-insoluble = 0.0;
        # 1 gram of fat is 9 kcal
        my Kilocalorie:D $kcal-per-g-fat = 9.0;
        # 1 gram of alcohol is 7 kcal
        my Kilocalorie:D $kcal-per-g-alcohol = 7.0;

        my Kilocalorie:D $calories-from-protein =
            $.protein * $kcal-per-g-protein;
        my Kilocalorie:D $calories-from-carbohydrates =
            $.carbohydrates.net * $kcal-per-g-carbohydrates;
        my Kilocalorie:D $calories-from-fiber-soluble =
            $.carbohydrates.fiber.soluble * $kcal-per-g-fiber-soluble;
        my Kilocalorie:D $calories-from-fiber-insoluble =
            $.carbohydrates.fiber.insoluble * $kcal-per-g-fiber-insoluble;
        my Kilocalorie:D $calories-from-fat =
            $.fat * $kcal-per-g-fat;
        my Kilocalorie:D $calories-from-alcohol =
            $.alcohol * $kcal-per-g-alcohol;
        my Kilocalorie:D $calories =
            [+] $calories-from-protein,
                $calories-from-carbohydrates,
                $calories-from-fiber-soluble,
                $calories-from-fiber-insoluble,
                $calories-from-fat,
                $calories-from-alcohol;
    }
}

# end role Macros }}}

# class Food {{{

class Food
{
    also does Macros;

    # name of this food
    has FoodName:D $.name is required;

    # serving size from which macros are derived
    has ServingSize:D $.serving-size is required;

    # this food is also known as these names
    has FoodName @.aka;

    # source of data
    has DataSource $.source;

    submethod BUILD(
        Str:D :$!name!,
        Str:D :$!serving-size!,
        Numeric:D :$protein!,
        Numeric:D :$carbs!,
        Numeric:D :$fat!,
        :fiber($f),
        Numeric :$alcohol,
        :$aka,
        Str :$source
        --> Nil
    )
    {
        $!protein = Rat($protein);
        {
            my Gram:D $total = Rat($carbs);
            my Fiber $fiber .= new($f) if $f;
            my %opts;
            %opts<total> = $total;
            %opts<fiber> = $fiber if $fiber;
            $!carbohydrates = Carbohydrates.new(|%opts);
        }
        $!fat = Rat($fat);
        $!alcohol = Rat($alcohol) if $alcohol;
        @!aka = |$aka if $aka;
        $!source = $source if $source;
    }

    method new(
        *%opts (
            Str:D :name($)! where .so,
            Str:D :serving-size($)! where .so,
            Numeric:D :protein($)! where * >= 0,
            Numeric:D :carbs($)! where * >= 0,
            Numeric:D :fat($)! where * >= 0,
            :fiber($),
            Numeric :alcohol($),
            :aka($),
            Str :source($)
        )
        --> Food:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %carbohydrates = $.carbohydrates.hash;
        my %hash =
            :$.name,
            :$.serving-size,
            :$.calories,
            :$.protein,
            :%carbohydrates,
            :$.fat,
            :$.alcohol;
        %hash<aka> = @.aka if @.aka;
        %hash<source> = $.source if $.source;
        %hash;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Food }}}
# class Pantry {{{

class Pantry
{
    has Food:D @.food is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my Hash:D @food = @.food.map({ .hash });
        my %hash = :@food;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Pantry }}}

# class Portion {{{

class Portion
{
    has FoodName:D $.food is required;
    has Serving:D $.servings is required;

    submethod BUILD(
        FoodName:D :$!food!,
        Numeric:D :$servings!
        --> Nil
    )
    {
        $!servings = Rat($servings);
    }

    method new(
        *%opts (
            Str:D :food($)! where .so,
            Numeric:D :servings($)! where * >= 0
        )
        --> Portion:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash =
            :$.food,
            :$.servings;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Portion }}}
# class Portionʹ {{{

class Portionʹ
{
    also is Portion;

    # this food, at this serving size, yields these macros
    has Macros:D $.macros is required;

    method new(
        *%opts (
            FoodName:D :food($)! where .so,
            Serving:D :servings($)! where .so,
            Macros:D :macros($)! where .so
        )
        --> Portion:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %macros = $.macros.hash;
        my %hash =
            :$.food,
            :$.servings,
            :%macros;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Portionʹ }}}
# class Meal {{{

class Meal
{
    has Date:D $!date is required;
    has Time:D $!time is required;
    has DateTime:D $!date-time is required;
    has Portion:D @!portion is required;

    # --- accessor {{{

    method date(::?CLASS:D:) { $!date }
    method time(::?CLASS:D:) { $!time }
    method date-time(::?CLASS:D:) { $!date-time }
    method portion(::?CLASS:D:) { @!portion }

    # --- end accessor }}}

    submethod BUILD(
        Date:D :$!date!,
        :%time!,
        :@portion!
        --> Nil
    )
    {
        $!time = Time.new(|%time);
        my UInt:D ($year,
                   $month,
                   $day) = $!date.year,
                           $!date.month,
                           $!date.day;
        my %date =
            :$year,
            :$month,
            :$day;
        $!date-time = DateTime.new(|%date, |$!time.hash);
        @!portion = @portion.map(-> %portion { Portion.new(|%portion) });
    }

    method new(
        *%opts (
            Date:D :date($)!,
            :time(%)!,
            :portion(@)!
        )
        --> Meal:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %date = Sustenance::Utils.hash($.date);
        my %time = $.time.hash;
        my %date-time = Sustenance::Utils.hash($.date-time);
        my Hash:D @portion = @.portion.map({ .hash });
        my %hash =
            :%date,
            :%time,
            :%date-time,
            :@portion;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Meal }}}
# class Mealʹ {{{

# same as C<Meal>, but with C<Portionʹ>s instead of C<Portion>s
class Mealʹ
{
    has Date:D $.date is required;
    has Time:D $.time is required;
    has DateTime:D $.date-time is required;
    has Portionʹ:D @.portionʹ is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %date = Sustenance::Utils.hash($.date);
        my %time = $.time.hash;
        my %date-time = Sustenance::Utils.hash($.date-time);
        my Hash:D @portionʹ = @.portionʹ.map({ .hash });
        my %hash =
            :%date,
            :%time,
            :%date-time,
            :portion(@portionʹ);
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Mealʹ }}}
# class Mealʹʹ {{{

class Mealʹʹ
{
    also is Mealʹ;

    # the C<Portionʹ>s in this C<Mealʹ> add up to these macros
    has Macros:D $.macros is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %date = Sustenance::Utils.hash($.date);
        my %time = $.time.hash;
        my %date-time = Sustenance::Utils.hash($.date-time);
        my Hash:D @portionʹ = @.portionʹ.map({ .hash });
        my Hash:D $macros = $.macros.hash;
        my %hash =
            :%date,
            :%time,
            :%date-time,
            :portion(@portionʹ),
            :$macros;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

# end class Mealʹʹ }}}
# class DietLog {{{

class DietLog
{
    has Mealʹʹ:D @.mealʹʹ is required;

    # the macros in all C<Mealʹʹ>s add up to these macros
    has Macros:D $.macros is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my Hash:D @mealʹʹ = @.mealʹʹ.map({ .hash });
        my Hash:D $macros = $.macros.hash;
        my %hash =
            :meal(@mealʹʹ),
            :$macros;
    }
}

# end class DietLog }}}

# multiply {{{

# --- Fiber {{{

multi sub multiply(
    Fiber:D $fiber,
    Numeric:D $num
    --> Fiber:D
)
{
    my Gram:D $total = $fiber.total * $num;
    my Fraction:D $percent-insoluble = $fiber.percent-insoluble;
    my Fiber $multiply .= new([$total, $percent-insoluble]);
}

multi sub infix:<*>(
    Fiber:D $fiber,
    Numeric:D $num
    --> Fiber:D
) is export
{
    my Fiber:D $multiply = multiply($fiber, $num);
}

multi sub infix:<*>(
    Numeric:D $num,
    Fiber:D $fiber
    --> Fiber:D
) is export
{
    my Fiber:D $multiply = multiply($fiber, $num);
}

# --- end Fiber }}}
# --- Carbohydrates {{{

multi sub multiply(
    Carbohydrates:D $carbohydrates,
    Numeric:D $num
    --> Carbohydrates:D
)
{
    my Gram:D $total = $carbohydrates.total * $num;
    my Fiber:D $fiber = multiply($carbohydrates.fiber, $num);
    my Carbohydrates $multiply .= new(:$total, :$fiber);
}

multi sub infix:<*>(
    Carbohydrates:D $carbohydrates,
    Numeric:D $num
    --> Carbohydrates:D
) is export
{
    my Carbohydrates:D $multiply = multiply($carbohydrates, $num);
}

multi sub infix:<*>(
    Numeric:D $num,
    Carbohydrates:D $carbohydrates
    --> Carbohydrates:D
) is export
{
    my Carbohydrates:D $multiply = multiply($carbohydrates, $num);
}

# --- end Carbohydrates }}}
# --- Food {{{

# yield C<Portionʹ>, because C<Food> remains constant
multi sub multiply(
    Food:D $food,
    Numeric:D $num
    --> Portionʹ:D
)
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

multi sub infix:<*>(
    Food:D $food,
    Numeric:D $num
    --> Portionʹ:D
) is export
{
    my Portionʹ:D $multiply = multiply($food, $num);
}

multi sub infix:<*>(
    Numeric:D $num,
    Food:D $food
    --> Portionʹ:D
) is export
{
    my Portionʹ:D $multiply = multiply($food, $num);
}

# --- end Food }}}

# end multiply }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0 nowrap:
