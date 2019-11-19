use v6;
use Sustenance::Types;

# class Food {{{

class Food
{
    has FoodName:D $.name is required;
    has ServingSize:D $.serving-size is required;
    # kcal per serving size of this food
    has Gram:D $.protein is required;
    # total carbohydrates, including all sources of fiber
    has Gram:D $.carbohydrates is required;
    has Gram:D $.fat is required;
    has Gram:D $.alcohol = 0.0;

    # 1 gram of protein is 4 kcal
    constant $KCAL-PER-G-PROTEIN = 4;
    # 1 gram of carbohydrates is 4 kcal
    constant $KCAL-PER-G-CARBOHYDRATES = 4;
    # 1 gram of fat is 9 kcal
    constant $KCAL-PER-G-FAT = 9;
    # 1 gram of alcohol is 7 kcal
    constant $KCAL-PER-G-ALCOHOL = 7;

    method calories(::?CLASS:D: --> Kilocalorie:D)
    {
        my Kilocalorie:D $calories-from-protein =
            $.protein * $KCAL-PER-G-PROTEIN;
        my Kilocalorie:D $calories-from-carbohydrates =
            $.carbohydrates * $KCAL-PER-G-CARBOHYDRATES;
        my Kilocalorie:D $calories-from-fat =
            $.fat * $KCAL-PER-G-FAT;
        my Kilocalorie:D $calories-from-alcohol =
            $.alcohol * $KCAL-PER-G-ALCOHOL;
        my Kilocalorie:D $calories =
            [+] $calories-from-protein,
                $calories-from-carbohydrates,
                $calories-from-fat,
                $calories-from-alcohol;
    }

    submethod BUILD(
        Str:D :$!name!,
        Str:D :$!serving-size!,
        Numeric:D :$protein!,
        Numeric:D :$carbs!,
        Numeric:D :$fat!,
        Numeric :$alcohol
        --> Nil
    )
    {
        $!protein = Rat($protein);
        $!carbohydrates = Rat($carbs);
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
            Numeric :alcohol($)
        )
        --> Food:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash =
            :$.name,
            :$.serving-size,
            :$.calories,
            :$.protein,
            :$.carbohydrates,
            :$.fat,
            :$.alcohol;
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
        my %hash = :$.food, :$.servings;
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
        my UInt:D ($year, $month, $day) = $!date.year, $!date.month, $!date.day;
        my %date = :$year, :$month, :$day;
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
        my %date = hash($.date);
        my %time = $.time.hash;
        my %date-time = hash($.date-time);
        my Hash:D @portion = @.portion.map({ .hash });
        my %hash = :%date, :%time, :%date-time, :@portion;
    }

    proto sub hash(|)
    {*}

    multi sub hash(DateTime:D $date-time --> Hash:D)
    {
        my (UInt:D $year, UInt:D $month, UInt:D $day) =
            $date-time.year, $date-time.month, $date-time.day;
        my (UInt:D $hour, UInt:D $minute, Rat:D $second) =
            $date-time.hour, $date-time.minute, $date-time.second;
        my %hash = :$year, :$month, :$day, :$hour, :$minute, :$second;
    }

    multi sub hash(Date:D $date --> Hash:D)
    {
        my (UInt:D $year, UInt:D $month, UInt:D $day) =
            $date.year, $date.month, $date.day;
        my %hash = :$year, :$month, :$day;
    }
}

# end class Meal }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0 nowrap:
