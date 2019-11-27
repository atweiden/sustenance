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
- implement milk-alternatives
  - cull those which don't have diy guides available
- implement spreads (e.g. nut and seed butters)

## functionality

```perl6
# calculate average macros
$sustenance.gen-average-macros;

# cross-reference food sources for calories/protein/carbs/fat
$sustenance.gen-report;
```
