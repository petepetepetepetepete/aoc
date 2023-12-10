#!/usr/bin/env perl

use strict;
use warnings;

my @dir = (
    # dx, dy, re next, re current
    [ -1, 0, '^[SLF-]$', '^[SJ7-]$' ],
    [ 1, 0,  '^[SJ7-]$', '^[SLF-]$' ],
    [ 0, -1, '^[SF7|]$', '^[SLJ|]$' ],
    [ 0, 1,  '^[SLJ|]$', '^[SF7|]$' ]
);

my @map = map { chomp; [ split //, $_ ] } <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};

# find position of start point
my ($sx, $sy) = map { ($_->[1], $_->[0]) } grep { $map[$_->[0]][$_->[1]] eq 'S' } map { my $y = $_; map { [ $y, $_ ] } (0..$max_x) } (0..$max_y);

my @n = grep {
    $_->[0] >= 0 && $_->[0] <= $max_x &&
    $_->[1] >= 0 && $_->[1] <= $max_y &&
    $map[$_->[1]][$_->[0]] =~ qr/$_->[2]/
} map { [ $sx+$_->[0], $sy+$_->[1], $_->[2] ] } @dir;

die unless @n == 2;
my ($x, $y) = @{$n[0]};

my ($px, $py) = ($sx, $sy);

my $dist = 1;
while ($x != $sx || $y != $sy) {
    my @n = grep {
        !($_->[0] == $px && $_->[1] == $py) && # don't backtrack
        $_->[0] >= 0 && $_->[0] <= $max_x && $_->[1] >= 0 && $_->[1] <= $max_y && # out of bounds
        $map[$_->[1]][$_->[0]] =~ qr/$_->[2]/ && # next connects to current
        $map[$y][$x] =~ qr/$_->[3]/ # current connects to next
    } map { [ $x+$_->[0], $y+$_->[1], $_->[2], $_->[3] ] } @dir;

    die "$px,$py,$map[$py][$px] -> $x,$y,$map[$y][$x]" unless @n == 1;

    ($px, $py) = ($x, $y);
    ($x, $y) = @{$n[0]};
    $dist++;
}

my $mid = $dist/2;
print $mid . "\n";

