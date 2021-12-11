#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/all/;

my @map = map { chomp; [ split // ] } <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};

my $step = 0;
while (++$step) {
    @map = map { my $y = $_; [ map { $map[$y][$_] + 1 } (0..$max_x) ] } (0..$max_y);
    my @flash = grep { $map[$_->[0]][$_->[1]] == 10 } map { my $y = $_; map { [$y,$_] } (0..$max_x) } (0..$max_y);
    while (my $pt = shift @flash) {
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
    last if all { $_ == 0 } map { my $y = $_; map { $map[$y][$_] } (0..$max_x) } (0..$max_y);
}

print $step . "\n";
