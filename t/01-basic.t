use v6;
use lib 'lib';
use Sustenance;

my Str:D $file = 't/data/sustenance.toml';
my Sustenance $sustenance .= new(:$file);

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
