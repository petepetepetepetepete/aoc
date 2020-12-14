#!/usr/bin/env perl

use strict;
use warnings;

<>; # ignore first line
my $bs = <>;
chomp $bs;
my @buses = split /,/, $bs;

my $ts = $buses[0];
my $diff = $ts;
for my $i (grep { $buses[$_] ne 'x' } (1..$#buses)) {
    while (($ts + $i) % $buses[$i] != 0) {
        $ts += $diff;
    }
    $diff *= $buses[$i];
}

print $ts . "\n";
