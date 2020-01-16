use v6;

# X::Sustenance::FoodMissing {{{

class X::Sustenance::FoodMissing
{
    also is Exception;

    has Str:D $.name is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message =
            sprintf(Q{Sorry, could not find matching food named %s}, $.name);
    }
}

# end X::Sustenance::FoodMissing }}}
# X::Sustenance::MealMissing {{{

class X::Sustenance::MealMissing
{
    also is Exception;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = 'Sorry, could not find matching meal';
    }
}

# end X::Sustenance::MealMissing }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0 nowrap:
