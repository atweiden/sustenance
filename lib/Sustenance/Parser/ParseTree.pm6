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

    # carbohydrates less all sources of fiber
    method net(::?CLASS:D: --> Gram:D)
    {
        my Gram:D $net = $.total - $.fiber.total;
    }
}

# end class Carbohydrates }}}
# class Food {{{

class Food
{
    has FoodName:D $.name is required;
    has ServingSize:D $.serving-size is required;
    has Gram:D $.protein is required;
    has Carbohydrates:D $.carbohydrates is required;
    has Gram:D $.fat is required;
    has Gram:D $.alcohol = 0.0;

    # 1 gram of protein is 4 kcal
    constant $KCAL-PER-G-PROTEIN = 4;
    # 1 gram of carbohydrates is 4 kcal
    constant $KCAL-PER-G-CARBOHYDRATES = 4;
    # 1 gram of soluble fiber is 2 kcal
    constant $KCAL-PER-G-FIBER-SOLUBLE = 2;
    # 1 gram of insoluble fiber is 0 kcal
    constant $KCAL-PER-G-FIBER-INSOLUBLE = 0;
    # 1 gram of fat is 9 kcal
    constant $KCAL-PER-G-FAT = 9;
    # 1 gram of alcohol is 7 kcal
    constant $KCAL-PER-G-ALCOHOL = 7;

    submethod BUILD(
        Str:D :$!name!,
        Str:D :$!serving-size!,
        Numeric:D :$protein!,
        Numeric:D :$carbs!,
        Numeric:D :$fat!,
        :fiber($f),
        Numeric :$alcohol
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
    }

    method new(
        *%opts (
            Str:D :name($)! where .so,
            Str:D :serving-size($)! where .so,
            Numeric:D :protein($)! where * >= 0,
            Numeric:D :carbs($)! where * >= 0,
            Numeric:D :fat($)! where * >= 0,
            :fiber($),
            Numeric :alcohol($)
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
    }

    method calories(::?CLASS:D: --> Kilocalorie:D)
    {
        my Kilocalorie:D $calories-from-protein =
            $.protein * $KCAL-PER-G-PROTEIN;
        my Kilocalorie:D $calories-from-carbohydrates =
            $.carbohydrates.net * $KCAL-PER-G-CARBOHYDRATES;
        my Kilocalorie:D $calories-from-fiber-soluble =
            $.carbohydrates.fiber.soluble * $KCAL-PER-G-FIBER-SOLUBLE;
        my Kilocalorie:D $calories-from-fiber-insoluble =
            $.carbohydrates.fiber.insoluble * $KCAL-PER-G-FIBER-INSOLUBLE;
        my Kilocalorie:D $calories-from-fat =
            $.fat * $KCAL-PER-G-FAT;
        my Kilocalorie:D $calories-from-alcohol =
            $.alcohol * $KCAL-PER-G-ALCOHOL;
        my Kilocalorie:D $calories =
            [+] $calories-from-protein,
                $calories-from-carbohydrates,
                $calories-from-fiber-soluble,
                $calories-from-fiber-insoluble,
                $calories-from-fat,
                $calories-from-alcohol;
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
}

# end class Portion }}}
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
}

# end class Meal }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0 nowrap:
