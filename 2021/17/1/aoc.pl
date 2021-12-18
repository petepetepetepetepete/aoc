#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min max/;

my ($min_x,$max_x,$min_y,$max_y) = <> =~ m/^target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/;

print max(map { my $y = $_; map { height($_,$y) } (-$max_x..$max_x) } ($min_y..abs($min_y))) . "\n";

sub height {
    my ($dx, $dy) = @_;
    my ($x,$y) = (0) x 2;
    my $res = $y;
    while ($dx != 0 || $dy >= 0 || $y >= $min_y) {
        $res = max($res, $y);
        return $res if $x >= $min_x && $x <= $max_x && $y >= $min_y && $y <= $max_y;
        $x += $dx;
        $y += $dy;
        $dx-- if $dx > 0;
        $dx++ if $dx < 0;
        $dy--;
    }
    return;
}
