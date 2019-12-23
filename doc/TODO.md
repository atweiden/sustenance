# todo

## testing

- add travis-ci

## pantry

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

```perl6
# calculate average macros
$sustenance.gen-average-macros;

# cross-reference food sources for calories/protein/carbs/fat
$sustenance.gen-report;

# calculate dollars per calorie
$sustenance.gen-report(:budget);
```

- acidity levels
- oxylate content
