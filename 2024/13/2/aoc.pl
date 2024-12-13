#!/usr/bin/env perl

use strict;
use warnings;

use Math::Prime::Util qw/lcm/;

my $in = do { local $/; <> };

my $cost;
while ($in =~ m/Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)\n/g) {
    my ($ax, $ay, $bx, $by, $px, $py) = ($1, $2, $3, $4, $5, $6);

    $px += 10000000000000;
    $py += 10000000000000;
    
    $cost += min_cost_prize($ax, $ay, $bx, $by, $px, $py);
}

print $cost . "\n";

sub min_cost_prize {
    my ($x1, $y1, $x2, $y2, $px, $py) = @_;

    # subtraction of algebraic expressions to eliminate one variable
    # $x1*M + $x2*N == $px
    # $y1*M + $y2*N == $py
    my $lcm = lcm($x1, $y1);
    my $mult1 = $lcm / $x1;
    my $mult2 = $lcm / $y1;

    # $mult1 * $x2 == $mult1 * $px
    # $mult2 * $y2 == $mult2 * $py
    # (($mult1 * $x2) - ($mult2 * $y2)) == (($mult1 * $px) - ($mult2 * $py))

    my $b_press = (($mult1 * $px) - ($mult2 * $py)) / (($mult1 * $x2) - ($mult2 * $y2));
    return 0 unless int($b_press) == $b_press;
    my $a_press = ($px - $x2 * $b_press) / $x1;

    return 0 unless int($a_press) == $a_press;
    return 0 if $a_press < 0 or $b_press < 0;

    return 3 * $a_press + $b_press;
}

