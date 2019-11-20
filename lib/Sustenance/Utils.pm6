use v6;
unit class Sustenance::Utils;

# hash C<Dateish> types by hand because perl 6 doesn't do this for us
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

# vim: set filetype=perl6 foldmethod=marker foldlevel=0 nowrap:
