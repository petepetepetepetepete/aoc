#!/usr/bin/env perl

use strict;
use warnings;

my @map = map { chomp; [ split //, $_ ] } <>;

my $result = 0;
for my $y (0..$#map) {
    my $num = '';
    my $valid = 0;
    my $max_x = $#{$map[$y]};
    for my $x (0..$max_x) {
        if ($map[$y][$x] =~ m/[0-9]/) {
            $num .= $map[$y][$x];

            OUTER:
            for my $x1 (-1..1) {
                next if $x + $x1 < 0;
                next if $x + $x1 > $max_x;
                for my $y1 (-1..1) {
                    next if $x1 == 0 and $y1 == 0;
                    next if $y + $y1 < 0;
                    next if $y + $y1 > $#map;

                    if ($map[$y+$y1][$x+$x1] =~ m/[^0-9.]/) {
                        $valid++;
                        last OUTER;
                    }
                }
            }
        }
        if ($x == $max_x || $map[$y][$x] !~ m/[0-9]/) {
            $result += $num if $valid;
            $num = '';
            $valid = 0;
        }
    }
}

print $result . "\n";
