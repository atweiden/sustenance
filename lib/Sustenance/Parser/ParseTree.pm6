use v6;
use Sustenance::Types;

# class Food {{{

class Food
{
    has FoodName:D $.name is required;
    has ServingSize:D $.serving-size is required;
    has Calories:D $.calories is required;
    has Protein:D $.protein is required;
    has Carbohydrates:D $.carbohydrates is required;
    has Fat:D $.fat is required;

    submethod BUILD(
        Str:D :$!name!,
        Str:D :$!serving-size!,
        Numeric:D :$calories!,
        Numeric:D :$protein!,
        Numeric:D :$carbs!,
        Numeric:D :$fat!
        --> Nil
    )
    {
        $!calories = Rat($calories);
        $!protein = Rat($protein);
        $!carbohydrates = Rat($carbs);
        $!fat = Rat($fat);
    }

    method new(
        *%opts (
            Str:D :$name! where .so,
            Str:D :$serving-size! where .so,
            Numeric:D :$calories! where * >= 0,
            Numeric:D :$protein! where * >= 0,
            Numeric:D :$carbs! where * >= 0,
            Numeric:D :$fat! where * >= 0
        )
        --> Food:D
    )
    {
        self.bless(|%opts);
    }
}

# end class Food }}}
# class Pantry {{{

class Pantry
{
    has Food:D @.food is required;
}

# end class Pantry }}}
# class Time {{{

class Time
{
    has UInt:D $.hour is required;
    has UInt:D $.minute is required;
    has Rat:D $.second is required;
}

# end class Time }}}
# class Portion {{{

class Portion
{
    has FoodName:D $.food is required;
    has Servings:D $.servings is required;

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
            Str:D :$food! where .so,
            Numeric:D :$servings! where * >= 0
        )
        --> Portion:D
    )
    {
        self.bless(|%opts);
    }
}

# end class Portion }}}
# class Meal {{{

class Meal
{
    has Date:D $.date is required;
    has Time:D $.time is required;
    has Portion:D @.portion is required;

    submethod BUILD(
        Date:D :$!date!,
        :%time!,
        :@portion!
        --> Nil
    )
    {
        $!time = Time.new(|%time);
        @!portion = @portion.map(-> %portion { Portion.new(|%portion) });
    }

    method new(
        *%opts (
            Date:D :$date!,
            :%time!,
            :@portion!
        )
        --> Meal:D
    )
    {
        self.bless(|%opts);
    }
}

# end class Meal }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
