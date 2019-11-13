use v6;
unit class Concentric;

=begin pod
=head NAME

Concentric

=head SYNOPSIS

lightly active athlete weighing 59 kg

    use Concentric;
    Concentric.gen-target-macros('lightly-active', 59);

=head DESCRIPTION

Calculates target calories for lean muscle mass gains, including
recommended protein intake.

=head base metabolic rate (bmr)

B<base metabolic rate> represents how many calories you’d burn each
day if you did literally nothing but lie in bed
=end pod

method gen-bmr($lean-mass-in-kg)
{
    370 + (21.6 * $lean-mass-in-kg);
}

=begin pod
=head actual daily burn

B<actual daily burn> is the number of calories you, as an athlete,
must consume per day in order to maintain your current body composition

=head2 activity level

most of you will fall in the range of moderately active to extra active
depending on how frequently you're training and exercising as well as
how your daily life stacks up in terms of activity
=end pod

method gen-adb($bmr, $activity-level)
{
    gen-adb($bmr, $activity-level);
}

# if you get little or no exercise
multi sub gen-adb($bmr, $activity-level where 'sedentary') { $bmr * 1.2 }
# if you do light exercise 1-3 days per week
multi sub gen-adb($bmr, $activity-level where 'lightly-active') { $bmr * 1.375 }
# if you do moderate exercise 3-5 days per week
multi sub gen-adb($bmr, $activity-level where 'moderately-active') { $bmr * 1.55 }
# if you do hard exercise 6-7 days per week
multi sub gen-adb($bmr, $activity-level where 'very-active') { $bmr * 1.725 }
# if you do very hard exercise and have a physical job or do 2x training
multi sub gen-adb($bmr, $activity-level where 'extra-active') { $bmr * 1.9 }

=begin pod
=head recommended caloric intake

if you are looking to gain muscle mass, you will need to eat more than
your maintenance calorie intake — a calorie surplus

ideally, you should add between 250-500 extra calories per day to your
actual daily burn

this will result in 0.5-1 lb of weight gain per week, and will help you
stay lean as you build muscle

any surplus greater than 500 calories can create additional fat mass,
which is not productive to your goals
=end pod

method gen-recommended-caloric-intake($adb)
{
    my $min = $adb + 250;
    my $max = $adb + 500;
    $min..$max;
}


=begin pod
=head recommended protein intake

studies have shown efficacy of 1.4g protein per kg body weight is similar
to efficacy of 1.6g protein per kg body weight

studies have shown uselessness of greater than 1.6g protein per kg
body weight
=end pod

method gen-recommended-protein-intake($lean-mass-in-kg)
{
    my $min = $lean-mass-in-kg * 1.4;
    my $max = $lean-mass-in-kg * 1.6;
    $min..$max;
}

sub format-recommendations(
    $recommended-caloric-intake,
    $recommended-protein-intake
)
{
    my $cal-min = $recommended-caloric-intake.min;
    my $cal-max = $recommended-caloric-intake.max;
    my $pro-min = $recommended-protein-intake.min;
    my $pro-max = $recommended-protein-intake.max;
    qq:to/EOF/.trim
    ------------------------------------------------------------------------------
    calories (minimum): $cal-min
    calories (maximum): $cal-max
    protein (minimum): {$pro-min}g
    protein (maximum): {$pro-max}g
    ------------------------------------------------------------------------------
    EOF
}

method gen-target-macros($activity-level, $lean-mass-in-kg)
{
    my $bmr =
        Concentric.gen-bmr($lean-mass-in-kg);
    my $adb =
        Concentric.gen-adb($bmr, $activity-level);
    my $recommended-caloric-intake =
        Concentric.gen-recommended-caloric-intake($adb);
    my $recommended-protein-intake =
        Concentric.gen-recommended-protein-intake($lean-mass-in-kg);
    my $format-recommendations =
        format-recommendations(
            $recommended-caloric-intake,
            $recommended-protein-intake
        );
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
