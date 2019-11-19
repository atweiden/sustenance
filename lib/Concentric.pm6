use v6;
unit class Concentric;

=begin pod
=head NAME

Concentric

=head SYNOPSIS

    # lightly active male athlete, age 31, weighing 59 kg at 175.26 cm
    use Concentric;
    Concentric.new(
        :weight(59),
        :height(175.26),
        :age(31),
        :gender<male>,
        :activity-level<lightly-active>
    ).gist;

=head DESCRIPTION

Estimates daily caloric requirements for weight maintenance, muscle
gains and fat loss.

First calculates Basal Metabolic Rate (BMR) with the Mifflin St Jeor
equation.

Then calculates Total Daily Energy Expenditure (TDEE) by taking the
product of BMR and the appropriate Katch-McArdle multiplier for a given
activity level.
=end pod

# weight in kilograms
has $.weight is required;
# height in centimeters
has $.height is required;
# age in years
has $.age is required;
# gender
has $.gender is required;
# activity level
has $.activity-level is required;

# basal metabolic rate (mifflin st jeor equation)
has $!bmr =
    Concentric.gen-bmr(:$!weight, :$!height, :$!age, :$!gender);
# total daily energy expenditure (katch-mcardle multipliers)
has $!tdee =
    Concentric.gen-tdee(:$!bmr, :$!activity-level);
# caloric recommendations for muscle gain
has $!recommended-calories-muscle-gains =
    Concentric.gen-recommended-caloric-intake(:$!tdee, :goal<muscle-gains>);
# caloric recommendations for fat loss
has $!recommended-calories-fat-loss =
    Concentric.gen-recommended-caloric-intake(:$!tdee, :goal<fat-loss>);
# protein intake recommendations
has $!recommended-protein-intake =
    Concentric.gen-recommended-protein-intake(:$!weight);

method gist(::?CLASS:D:)
{
    my $bmr =
        fmtnum($!bmr);
    my $tdee =
        fmtnum($!tdee);
    my $muscle-gains-calories-min =
        fmtnum($!recommended-calories-muscle-gains.min);
    my $muscle-gains-calories-max =
        fmtnum($!recommended-calories-muscle-gains.max);
    my $fat-loss-calories-min =
        fmtnum($!recommended-calories-fat-loss.min);
    my $fat-loss-calories-max =
        fmtnum($!recommended-calories-fat-loss.max);
    my $protein-min =
        fmtnum($!recommended-protein-intake.min);
    my $protein-max =
        fmtnum($!recommended-protein-intake.max);
    qq:to/EOF/.trim
    # Calories

    Your estimated daily calorie maintenance level is: 「$tdee」

        Basal Metabolic Rate (BMR): $bmr calories/day
        Total Daily Energy Expenditure (TDEE): $tdee calories/day

    For muscle gains, consume between $muscle-gains-calories-min and $muscle-gains-calories-max calories per day.

    For fat loss, consume between $fat-loss-calories-min and $fat-loss-calories-max calories per day.

    # Protein

    Get {$protein-min}-{$protein-max}g of protein per day.

    # Fat

    Get 20-35% of your daily calories from healthy sources of fat.

    # Carbohydrates

    Get the rest of your daily calories from healthy sources of carbohydrates.
    EOF
}

method hash(::?CLASS:D:)
{
    my %hash =
        :$!bmr,
        :$!tdee,
        :$!recommended-calories-muscle-gains,
        :$!recommended-calories-fat-loss,
        :$!recommended-protein-intake;
}

=begin pod
=head Basal Metabolic Rate (BMR)

B<Basal Metabolic Rate (BMR)> is how many calories you'd burn each day
if you did literally nothing but lie in bed. We calculate it using the
L<https://en.wikipedia.org/wiki/Basal_metabolic_rate|Mifflin St Jeor
equation>.

BMR does not include calories burned from physical activity, the process
of digestion, or things like walking from one room to another.
=end pod

method gen-bmr(
    :$weight! where .so,
    :$height! where .so,
    :$age! where .so,
    :$gender! where .so
)
{
    my $bmr = gen-bmr(:$weight, :$height, :$age, :$gender);
}

# mifflin st jeor equation (without gender-specific parameter for dry)
sub mifflin-st-jeor-shared-gender(
    :$weight! where .so,
    :$height! where .so,
    :$age! where .so
)
{
    my $bmr-shared-gender =
        (10 * $weight)
      + (6.25 * $height)
      - (5 * $age);
}

# mifflin st jeor equation (male)
multi sub gen-bmr(
    :$weight! where .so,
    :$height! where .so,
    :$age! where .so,
    :gender($)! where 'male'
)
{
    my $s = 5;
    my $bmr-male =
        mifflin-st-jeor-shared-gender(:$weight, :$height, :$age) + $s;
}

# mifflin st jeor equation (female)
multi sub gen-bmr(
    :$weight! where .so,
    :$height! where .so,
    :$age! where .so,
    :gender($)! where 'female'
)
{
    my $s = -161;
    my $bmr-female =
        mifflin-st-jeor-shared-gender(:$weight, :$height, :$age) + $s;
}

=begin pod
=head Total Daily Energy Expenditure (TDEE)

B<Total Daily Energy Expenditure (TDEE)> is the total number of calories
you burn in a given day. TDEE is determined by four key factors:

=item Basal Metabolic Rate
=item Thermic Effect of Food
=item Non-Exercise Activity Thermogenesis
=item Thermic Effect of Activity (Exercise)

For simplicity, we condense the three factors beyond BMR into a single
Katch-McArdle multiplier. This multiplier is adjusted based on your
I<Activity Level>.

=head2 Activity Level

If you get little or no exercise, your activity level is: C<sedentary>.

If you do light exercise 1-3 days per week, your activity level is:
C<lightly-active>.

If you do moderate exercise 3-5 days per week, your activity level is:
C<moderately-active>.

If you do hard exercise 6-7 days per week, your activity level is:
C<very-active>.

If you do very hard exercise and have a physical job or do two-a-day
training, your activity level is: C<extra-active>.

Most of you will fall in the range of moderately active to extra active
depending on how frequently you're training and exercising as well as
how your daily life stacks up in terms of activity.
=end pod

method gen-tdee(:$bmr! where .so, :$activity-level! where .so)
{
    gen-tdee($bmr, $activity-level);
}

# if you get little or no exercise
multi sub gen-tdee($bmr, $activity-level where 'sedentary')
{
    $bmr * 1.2;
}

# if you do light exercise 1-3 days per week
multi sub gen-tdee($bmr, $activity-level where 'lightly-active')
{
    $bmr * 1.375;
}

# if you do moderate exercise 3-5 days per week
multi sub gen-tdee($bmr, $activity-level where 'moderately-active')
{
    $bmr * 1.55;
}

# if you do hard exercise 6-7 days per week
multi sub gen-tdee($bmr, $activity-level where 'very-active')
{
    $bmr * 1.725;
}

# if you do very hard exercise and have a physical job or do 2x training
multi sub gen-tdee($bmr, $activity-level where 'extra-active')
{
    $bmr * 1.9;
}

=begin pod
=head Recommended Caloric Intake

=head2 Goal: Muscle Gains

If your goal is to gain muscle, you will need to consume more calories
than your TDEE — a caloric surplus.

Start by adding between 250-500 extra calories per day to your TDEE.
Adjust your daily caloric intake in accordance with your results.

=head2 Goal: Fat Loss

If your goal is to lose fat, you will need to consume less calories than
your TDEE — a caloric deficit.

Start by subtracting between 250-500 calories per day from your TDEE,
and adjust your daily caloric intake in accordance with your results.
=end pod

method gen-recommended-caloric-intake(:$tdee! where .so, :$goal! where .so)
{
    gen-recommended-caloric-intake(:$tdee, :$goal);
}

multi sub gen-recommended-caloric-intake(
    :$tdee! where .so,
    :goal($)! where 'muscle-gains'
)
{
    my $min = $tdee + 250;
    my $max = $tdee + 500;
    $min..$max;
}

multi sub gen-recommended-caloric-intake(
    :$tdee! where .so,
    :goal($)! where 'fat-loss'
)
{
    my $min = $tdee - 500;
    my $max = $tdee - 250;
    $min..$max;
}

=begin pod
=head Recommended Protein Intake

Studies have shown the efficacy of consuming 1.4 grams of protein per
kilogram body weight is similar to the efficacy of consuming 1.6 grams
of protein per kilogram body weight.

Studies have shown consuming greater than 1.6 grams of protein per
kilogram body weight is no more effective than consuming 1.6 grams per
kilogram body weight.

Therefore, we recommend consuming between 1.4-1.6 grams of protein per
kilogram body weight.
=end pod

method gen-recommended-protein-intake(:$weight! where .so)
{
    my $min = $weight * 1.4;
    my $max = $weight * 1.6;
    $min..$max;
}

sub fmtnum($number)
{
    sprintf('%.0f', $number);
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
