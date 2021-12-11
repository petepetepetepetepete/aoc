#!/usr/bin/env perl

use strict;
use warnings;

my @map = map { chomp; [ split // ] } <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};
my $res = 0;

for my $i (1..100) {
    @map = map { my $y = $_; [ map { $map[$y][$_] + 1 } (0..$max_x) ] } (0..$max_y);
    my @flash = grep { $map[$_->[0]][$_->[1]] == 10 } map { my $y = $_; map { [$y,$_] } (0..$max_x) } (0..$max_y);
    while (my $pt = shift @flash) {
        $res++;
        push @flash, grep {
            $_->[0] >= 0 && $_->[0] <= $max_y &&
            $_->[1] >= 0 && $_->[1] <= $max_x &&
            !($_->[0] == $pt->[0] && $_->[1] == $pt->[1]) &&
            ++$map[$_->[0]][$_->[1]] == 10 
        } map {
            my $y = $_;
            map { [$y,$_] } ($pt->[1]-1..$pt->[1]+1)
        } ($pt->[0]-1..$pt->[0]+1);
    }
    @map = map { my $y = $_; [ map { $map[$y][$_] < 10 ? $map[$y][$_] : 0 } (0..$max_x) ] } (0..$max_y);
}

print $res . "\n";
