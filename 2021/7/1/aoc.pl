#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min max sum/;

my @x = split /,/, <>;
chomp $x[-1];

my $min = 999999999;
for my $i (min(@x)..max(@x)) {
    $min = min($min, sum(map { abs($_-$i) } @x));
}
print $min . "\n";


