# todo

## core

- implement `Pantry.gen-macros`
  - because
    - generating macros requires parsing the pantry
      - it makes sense to scope the `gen-macros` method to `Pantry`
    - it would facilitate untyped on-the-fly caloric estimation
      - e.g.
        ```raku
        my Pantry $pantry .= new(:$file);
        $pantry.gen-macros(:food<chickpea>, :servings(1));
        $pantry.gen-macros(%(:food<chickpea>, :servings(1)));
        $pantry.gen-macros(%(:food<chickpea>, :servings(1)),
                           %(:food<avocado>, :servings(1)));
        $pantry.gen-macros('chickpea:1');
        $pantry.gen-macros('chickpea', 1);
        ```
    - it would clean up `lib/Sustenance.pm6`
- implement separation between pantry and meal log
  - e.g.
    - put sample-pantry.toml into resources directory
    - install sample-pantry.toml as `~/.config/sustenance/pantry.toml`
      at runtime
      - see also
        - how https://github.com/atweiden/tantum does it
- implement diet plan profiles
  - because
    - that way you won't have to pass tons of cli flags constantly
  - involves implementing
    - main profile
      - e.g.
        - `sustenance show dietplan andy`
    - subprofiles
      - e.g.
        - `sustenance show dietplan andy lazy`
        - `sustenance show dietplan andy poppeye`
  - e.g.
    ```toml
    [[profile]]
    name = 'andy'
    weight = 59.4206
    height = 175.26
    age = 31
    gender = 'male'
    activity-level = 'moderately-active'

      [[profile.mod]]
      modname = 'lazy'
      activity-level = 'lightly-active'

      [[profile.mod]]
      modname = 'poppeye'
      activity-level = 'very-active'
    ```
- implement food derivatives input syntax
  - e.g.
    ```toml
    [[portion]]
    name = 'combo'
    from = {
      'black-bean': 0.5,
      'pinto-bean': 0.5
    }
    serving = 1
    ```

## testing

- add travis-ci

## sample pantry

- convert 1 tbsp measures to 100g
- implement missing soluble/insoluble fiber data
  - flour
    - almond flour
    - chestnut flour
    - hemp seed meal
    - lupin flour
    - pumpkin seed meal
    - quinoa flour
    - sunflower seed meal
    - tiger nut flour
  - dried fruit
    - dried goji berry
    - dried mango
    - dried papaya
    - dried pineapple
  - fresh fruit
    - ataulfo mango
    - banana pepper
    - jackfruit
  - fungi
    - truffle
    - nutritional yeast
  - grain
    - farro
  - herb
    - all
  - legume
    - borlotti bean / cranberry bean
    - cannellini bean
    - fava bean
    - lupin bean
    - lupin flake
    - marama bean
    - vanilla bean
    - pigeon pea
  - spice
    - all
  - vegetable
    - pearl onion
- implement missing food from mayumi's kitchen cookbook
  - grains
    - millet
    - barley
      - pearled-barley
      - hulled-barley
    - hato-mugi
      - aka pearl-barley
        - not to be confused with pearled-barley
  - vegetables
    - daikon-radish
    - komatsuna
      - aka japanese-mustard-spinach
    - burdock
    - lotus root
  - sea vegetables
    - kombu
    - wakame
    - hijiki
    - arame
- implement missing food from vegan richa's indian kitchen cookbook
- implement missing food from teff love cookbook
  - ajwain
    - aka
      - bishop’s weed
      - carom seed
      - netch azmud (amharic)
      - ajwain (hindi)
  - prepared horseradish
    - grated horseradish root preserved in vinegar
  - new mexico chile powder
  - bell pea / marrone pea
  - du poy lentils
    - aka french lentils
  - textured soy protein
  - corn starch
  - oat flour
  - potato starch
    - potato starch extracted from potatoes
    - not to be confused with potato flour
      - made from pulverized potatoes
  - sorghum flour
    - aka jowar (hindi)
  - baking powder
  - baking soda
  - candied ginger
  - cream of tartar
  - instant yeast
    - ideally rapid rise by fleischmann’s
  - lasagna noodles
  - rice paper
    - aka banh trang (vietnamese)
  - wine
  - koseret
    - aka kosearut
  - mitmita
  - shiro powder
    - look for
      - spicy variant as miten shiro, kay shiro
      - lightly-seasoned variant as white shiro, nech shiro
  - cashew pieces/flakes
  - beets
  - butternut squash
  - kale
  - okra
- implement milk-alternatives
  - cull those which don't have diy guides available
- implement spreads (e.g. nut and seed butters)

## functionality

```raku
# calculate average macros (with min/max records)
$sustenance.gen-report(:macros);

# cross-reference food sources of fat in average macros output
$sustenance.gen-report(:macros).cross-reference(:fat);

# calculate dollars per calorie
$sustenance.gen-report(:budget);

# calculate environmental impact of diet
$sustenance.gen-report(:sustainability);
```

- track
  - fat in depth
    - cholesterol
    - dha / epa / ala
    - saturated fat
  - carbs in depth
    - fructose
    - glucose
    - sucrose
    - sugar alcohols
      - e.g.
        - `sugar-alcohols.erythritol = 99`
      - with separate calorie counts by type of sugar alcohol
        - monosaccharide polyols or novel sugars
          - d-tagatose
            - 1.5 calories per gram
          - erythritol
            - 0.2 calories per gram
              - https://ec.europa.eu/food/sites/food/files/safety/docs/sci-com_scf_out175_en.pdf
              - https://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2008:285:0009:0012:EN:PDF
          - mannitol
            - 1.6 calories per gram
          - sorbitol
            - 2.6 calories per gram
          - xylitol
            - 2.4 calories per gram
        - disaccharide polyols or novel sugars
          - isomalt
            - 2 calories per gram
          - lactitol
            - 2 calories per gram
          - maltitol
            - 2.1 calories per gram
          - trehalose
            - 4 calories per gram
        - polysaccharide polyols
          - hsh
            - 3 calories per gram
        - nonnutritive sweeteners
          - acesulfame-k
            - 0 calories per gram
          - aspartame
            - 4 calories per gram
          - neotame
            - 0 calories per gram
          - saccharin
            - 0 calories per gram
          - sucralose
            - 0 calories per gram
      - https://www.ncbi.nlm.nih.gov/pubmed/14760578
      - https://jandonline.org/article/S0002-8223(03)01658-4/fulltext
  - protein in depth
    - amino acids
      - essential
        - histidine
        - isoleucine
        - leucine
        - lysine
        - methionine
        - phenylalanine
        - threonine
        - tryptophan
        - valine
      - non-essential
        - alanine
        - arginine
        - asparagine
        - aspartic acid
        - cysteine
        - glutamic acid
        - glutamine
        - glycine
        - proline
        - serine
        - tyrosine
  - vitamins
    - vitamin a
    - vitamin b6 (folate)
    - vitamin b9
    - vitamin b12
    - vitamin c
    - vitamin d
    - vitamin k2
  - minerals
    - calcium
    - copper
    - iodine
    - iron
    - magnesium
    - manganese
    - potassium
    - selenium
    - sodium
    - zinc
  - cost of food
  - alkaline- vs acid-formation of food
  - environmental impact of diet
    - requirements of
      - land
      - water
    - greenhouse gas emissions
- implement recommendations from
  - source
    - http://www.eatrightpro.org/~/media/eatrightpro%20files/practice/position%20and%20practice%20papers/position%20papers/nutritionathleticperf.ashx
    - https://www.nomeatathlete.com/nutrients/
  - e.g.
    - carbohydrate targets
- implement shorthand syntax for meal log
  - e.g.

```
[2019-12-22T18:00:00] dried-banana:1, dried-golden-kiwi:1

[2019-12-22T18:00:00]
dried-banana:1,
dried-golden-kiwi:1
```
