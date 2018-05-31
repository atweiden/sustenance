Todo
====

- implement `bin/sustenance` CLI
- add travis-ci

```perl6
# filter gen-macros by time range on date
$sustenance.gen-macros($date, %t1, %t2);
# filter gen-macros by time on date
$sustenance.gen-macros($date, %time);
# calculate average macros
$sustenance.gen-average-macros($d1, $d2);
$sustenance.gen-average-macros($date);
$sustenance.gen-average-macros;
```
