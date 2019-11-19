use v6;
unit class Sustenance::DietPlan;

=begin pod
=head NAME

Sustenance::DietPlan

=head SYNOPSIS

    # lightly active male athlete, age 31, weighing 59 kg at 175.26 cm
    use Sustenance::DietPlan;
    Sustenance::DietPlan.new(
        :weight(59),
        :height(175.26),
        :age(31),
        :gender<male>,
        :activity-level<lightly-active>
    ).gist;

=head DESCRIPTION

Creates rudimentary diet plan for weight maintenance, muscle gains and
fat loss.

First estimates Basal Metabolic Rate (BMR) with the Mifflin St Jeor
equation.

Then estimates Total Daily Energy Expenditure (TDEE) by taking the
product of BMR and the appropriate Katch-McArdle multiplier for a given
activity level.

Adds 250-500 calories on top of TDEE to estimate caloric intake
requirements for muscle gains.

Subtracts 250-500 calories from TDEE to estimate caloric intake
requirements for fat loss.

Recommends obtaining 1.4-1.6 grams of protein per kilogram body weight.

Recommends obtaining 20-35% of daily calories from healthy sources of fat.

Recommends obtaining remainder of daily calories from healthy sources
of carbohydrates.
=end pod

# body weight in kilograms
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
    Sustenance::DietPlan.gen-bmr(:$!weight, :$!height, :$!age, :$!gender);
# total daily energy expenditure (katch-mcardle multipliers)
has $!tdee =
    Sustenance::DietPlan.gen-tdee(:$!bmr, :$!activity-level);
# caloric recommendations for muscle gains
has $!calories-muscle-gains =
    Sustenance::DietPlan.gen-calories(:$!tdee, :goal<muscle-gains>);
# caloric recommendations for fat loss
has $!calories-fat-loss =
    Sustenance::DietPlan.gen-calories(:$!tdee, :goal<fat-loss>);
# protein intake recommendations
has $!protein =
    Sustenance::DietPlan.gen-protein(:$!weight);

method gist(::?CLASS:D:)
{
    my $bmr =
        fmtnum($!bmr);
    my $tdee =
        fmtnum($!tdee);
    my $muscle-gains-calories-min =
        fmtnum($!calories-muscle-gains.min);
    my $muscle-gains-calories-max =
        fmtnum($!calories-muscle-gains.max);
    my $fat-loss-calories-min =
        fmtnum($!calories-fat-loss.min);
    my $fat-loss-calories-max =
        fmtnum($!calories-fat-loss.max);
    my $protein-min =
        fmtnum($!protein.min);
    my $protein-max =
        fmtnum($!protein.max);

    my $gist-calories = do {
        my $maintenance =
            "Your estimated daily calorie maintenance level is: 「$tdee」";
        my $maintenance-bmr =
            "Basal Metabolic Rate (BMR): $bmr calories/day";
        my $maintenance-tdee =
            "Total Daily Energy Expenditure (TDEE): $tdee calories/day";
        my $muscle-gains =
            'For muscle gains, consume between '
            ~ $muscle-gains-calories-min
            ~ ' and '
            ~ $muscle-gains-calories-max
            ~ ' calories per day.';
        my $fat-loss =
            'For fat loss, consume between '
            ~ $fat-loss-calories-min
            ~ ' and '
            ~ $fat-loss-calories-max
            ~ ' calories per day.';
        qq:to/EOF/.trim;
        # Calories

        $maintenance

            $maintenance-bmr
            $maintenance-tdee

        $muscle-gains

        $fat-loss
        EOF
    }

    my $gist-protein = do {
        my $recommendation =
            "Get {$protein-min}-{$protein-max}g of protein per day.";
        qq:to/EOF/.trim;
        # Protein

        $recommendation
        EOF
    }

    my $gist-fat = do {
        my $recommendation =
            'Get 20-35% of your daily calories from healthy sources of fat.';
        qq:to/EOF/.trim;
        # Fat

        $recommendation
        EOF
    }

    my $gist-carbohydrates = do {
        my $recommendation =
            'Get the rest of your daily calories '
            ~ 'from healthy sources of carbohydrates.';
        qq:to/EOF/.trim;
        # Carbohydrates

        $recommendation
        EOF
    }

    my $gist = qq:to/EOF/.trim;
    $gist-calories

    $gist-protein

    $gist-fat

    $gist-carbohydrates
    EOF
}

sub fmtnum($number)
{
    sprintf('%.0f', $number);
}

method hash(::?CLASS:D:)
{
    my %recommended-calories =
        :muscle-gains({
            :min($!calories-muscle-gains.min),
            :max($!calories-muscle-gains.max)
        }),
        :fat-loss({
            :min($!calories-fat-loss.min),
            :max($!calories-fat-loss.max)
        });
    my %recommended-protein =
        :min($!protein.min),
        :max($!protein.max);
    my %hash =
        :$!bmr,
        :$!tdee,
        :%recommended-calories,
        :%recommended-protein;
}

=begin pod
=head Basal Metabolic Rate (BMR)

B<Basal Metabolic Rate (BMR)> is how many calories you'd burn each day
if you did literally nothing but lie in bed. We calculate it using the
L<https://en.wikipedia.org/wiki/Basal_metabolic_rate|Mifflin St Jeor
equation>.

BMR does not factor in calories burned from physical activity, the
process of digestion, or things like walking from one room to another.
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
factor called I<Activity Level>. The specified I<Activity Level> controls
the Katch-McArdle multiplier on BMR.

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

Muscle gains require creating a caloric surplus, i.e. consuming more
calories than your TDEE.

As a starting point, add 250-500 extra calories to your TDEE, and adjust
based on results.

=head2 Goal: Fat Loss

Fat loss requires creating a caloric deficit, i.e. consuming less calories
than your TDEE.

As a starting point, subtract 250-500 extra calories from your TDEE,
and adjust based on results.
=end pod

method gen-calories(:$tdee! where .so, :$goal! where .so)
{
    gen-calories(:$tdee, :$goal);
}

multi sub gen-calories(
    :$tdee! where .so,
    :goal($)! where 'muscle-gains'
)
{
    my $min = $tdee + 250;
    my $max = $tdee + 500;
    $min..$max;
}

multi sub gen-calories(
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
=end pod

method gen-protein(:$weight! where .so)
{
    my $min = $weight * 1.4;
    my $max = $weight * 1.6;
    $min..$max;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0 nowrap:
