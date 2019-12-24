use v6;

subset SomeStr of Str is export where *.so;
constant DataSource is export = SomeStr;
constant FoodName is export = SomeStr;
constant ServingSize is export = SomeStr;

subset Natural of Rat is export where * >= 0;
constant Gram is export = Natural;
constant Kilocalorie is export = Natural;
constant Microgram is export = Natural;

subset Positive of Rat is export where * > 0;
constant Serving is export = Positive;

subset Fraction of Rat is export where 0 <= * <= 1;

# class Time {{{

class Time
{
    has UInt:D $!hour is required;
    has UInt:D $!minute is required;
    has Rat:D $!second is required;

    # --- accessor {{{

    method hour(::?CLASS:D: --> UInt:D) { $!hour }
    method minute(::?CLASS:D: --> UInt:D) { $!minute }
    method second(::?CLASS:D: --> Rat:D) { $!second }

    # --- end accessor }}}

    multi submethod BUILD(
        UInt:D :$!hour!,
        UInt:D :$!minute!,
        Rat:D :$!second!
        --> Nil
    )
    {*}

    multi submethod BUILD(
        Str:D $t
        --> Nil
    )
    {
        my (Str:D $h,
            Str:D $m,
            Str:D $s) = $t.split(':');
        $!hour = Int($h);
        $!minute = Int($m);
        $!second = Rat($s);
    }

    proto method new(|)
    {*}

    multi method new(
        *%opts (
            UInt:D :hour($)!,
            UInt:D :minute($)!,
            Rat:D :second($)!
        )
        --> Time:D
    )
    {
        self.bless(|%opts);
    }

    # instantiate C<Time> from C<hh:mm:ss> string
    multi method new(
        Str:D $t
        --> Time:D
    )
    {
        self.bless($t);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash =
            :$!hour,
            :$!minute,
            :$!second;
    }

    method perl(::?CLASS:D: --> Str:D)
    {
        my Str:D $perl = %.hash.perl;
    }
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2 where {
        .hour eqv $t1.hour
            && .minute eqv $t1.minute
                && .second eqv $t1.second
    }
    --> Order:D
) is export
{
    my Order:D $cmp = Same;
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2 where {
        .hour eqv $t1.hour
            && .minute eqv $t1.minute
    }
    --> Order:D
) is export
{
    my Order:D $cmp = $t1.second cmp $t2.second;
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2 where {
        .hour eqv $t1.hour
    }
    --> Order:D
) is export
{
    my Order:D $cmp = $t1.minute cmp $t2.minute;
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2
    --> Order:D
) is export
{
    my Order:D $cmp = $t1.hour cmp $t2.hour;
}

multi sub in-time-range(
    Time:D $time,
    Time:D $t1 where { $time cmp $t1 ~~ More|Same },
    Time:D $t2 where { $time cmp $t2 ~~ Less|Same }
    --> Bool:D
) is export
{
    my Bool:D $in-time-range = True;
}

multi sub in-time-range(
    Time:D $,
    Time:D $,
    Time:D $
    --> Bool:D
) is export
{
    my Bool:D $in-time-range = False;
}

# end class Time }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0 nowrap:
