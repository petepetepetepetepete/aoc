#!/usr/bin/env perl

use strict;
use warnings;

use Graph;
use List::Util qw/sum/;

my @map = map {
    chomp;
    my @a = split //;
    [ @a, map { my $x = $_; map { ($_ + $x - 1) % 9 + 1 } @a } (1..4) ]
} <>;

my $max_y = $#map;
my $max_x = $#{$map[0]};

for my $i (1..4) {
    for my $j (0..$max_y) {
        push @map, [ map { ($_ + $i - 1) % 9 + 1 } @{$map[$j]} ];
    }
}

$max_y = $#map;

my $g = Graph->new(directed => 1);
for my $x (0..$max_x) {
    for my $y (0..$max_y) {
        my @p = ((map { ["$_,$y", $map[$y][$_]] } grep { $_ >= 0 && $_ <= $max_x } ($x-1,$x+1)),
                 (map { ["$x,$_", $map[$_][$x]] } grep { $_ >= 0 && $_ <= $max_y } ($y-1,$y+1)));
        $g->add_weighted_edge("$x,$y", $_->[0], $_->[1]) foreach @p;
    }
}

print sum(-$map[0][0], map { my @a = split /,/; $map[$a[1]][$a[0]] } $g->SP_Dijkstra("0,0", "$max_x,$max_y")) . "\n";

