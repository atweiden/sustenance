# Sustenance

Calorie tracker and diet planner

## Synopsis

### Count calories

In `sustenance.toml`:

```toml
# pantry
[[food]]
name = 'rolled-oats'
serving-size = '100g'
calories = 382.1
protein = 13.2
carbs = 67.7
fat = 6.5

# meals
[[meal]]
date = 2018-05-31
time = 10:15:00

  # eat 150g rolled oats
  [[meal.portion]]
  food = 'oats'
  servings = 1.5
```

**cli**:

```sh
export PERL6LIB=lib
bin/sustenance --date=2018-05-31 gen-macros sustenance.toml
```

**perl6**:

```perl6
use Sustenance;
my Date $date .= new('2018-05-31');
Sustenance.new(:file<sustenance.toml>).gen-macros($date);
```

### Make a diet plan

Make a diet plan for a lightly active male athlete, age 31, weighing 59
kg at 175.26 cm.

**cli**:

```sh
export PERL6LIB=lib
bin/sustenance \
  --weight=59.4206 \
  --height=175.26 \
  --age=31 \
  --gender=male \
  --activity-level=moderately-active \
  gen-diet-plan
```

**perl6**:

```perl6
use Sustenance::DietPlan;
Sustenance::DietPlan.new(
    :weight(59),
    :height(175.26),
    :age(31),
    :gender<male>,
    :activity-level<lightly-active>
).gist;
```

## Description

### Calorie tracking

Processes daily caloric intake from [TOML][TOML] meal
journal formatted per the [synopsis](#synopsis) (see also:
[doc/sample-pantry.toml](doc/sample-pantry.toml)).

The Sustenance meal journal must consist of at least one *food* entry
and at least one *meal* entry.

Each *food* entry must have:

key            | type
---            | ---
`name`         | string
`serving-size` | string
`calories`     | number
`protein`      | number
`carbs`        | number
`fat`          | number

Each *meal* entry must have:

key       | type
---       | ---
`date`    | date
`time`    | time
`portion` | array of hashes

Each meal *portion* must have:

key        | type
---        | ---
`food`     | string
`servings` | number

### Diet planning

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

## Installation

### Dependencies

- Rakudo Perl 6
- [Config::TOML][Config::TOML]

## Licensing

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.

[Config::TOML]: https://github.com/atweiden/config-toml
[TOML]: https://github.com/toml-lang/toml
