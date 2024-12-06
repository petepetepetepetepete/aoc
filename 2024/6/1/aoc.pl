#!/usr/bin/env perl

use strict;
use warnings;

my @map = map { chomp; [ split //, $_ ] } <>;

my $max_y = $#map;
my $max_x = $#{$map[0]};

my $d = 0;
my @dirs = (
    [ 0, -1 ],
    [ 1, 0 ],
    [ 0, 1 ],
    [ -1, 0 ],
);
my ($pt) = grep { $map[$_->[1]][$_->[0]] eq '^' } map { my $y = $_; map { [$_,$y] } (0..$max_x) } (0..$max_y);

while (1) {
    my ($nx, $ny) = map { $pt->[$_] + $dirs[$d][$_] } (0..1);
    last if $nx < 0 or $nx > $max_x or $ny < 0 or $ny > $max_y;

    if ($map[$ny][$nx] eq '#') {
        $d++;
        $d %= 4;
        next;
    }

    $map[$ny][$nx] = 'X';
    $pt = [$nx,$ny];
}

print scalar(grep { $map[$_->[1]][$_->[0]] eq 'X' } map { my $y = $_; map { [$_,$y] } (0..$max_x) } (0..$max_y)) . "\n";
