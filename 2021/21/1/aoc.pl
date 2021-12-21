#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min/;

my $die = 0;

my @board = (10, 1..9);
my @players = map { chomp; (split /: /)[-1] } <>;
my @scores = (0) x 2;

for (my $i = 0; $scores[($i+1) % 2] < 1000; $i++) {
    $players[$i % 2] += roll() foreach (1..3);
    $players[$i % 2] %= 10;
    $scores[$i % 2] += $board[$players[$i % 2]];
}

print ((min(@scores) * $die) . "\n");

sub roll {
    return ($die++ % 100) + 1;
}
