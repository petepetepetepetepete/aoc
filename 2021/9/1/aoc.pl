#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @map;
while (my $line = <>) {
    chomp $line;
    push @map, [ split //, $line ];
}

my $max_y = $#map;
my $max_x = $#{$map[0]};

print sum(
    map {
        $map[$_->[0]][$_->[1]] + 1
    } grep {
        my $pt = $_;
        my @compare = (
            (map { [$_,$pt->[1]] } grep { $_ >= 0 && $_ <= $max_y }($pt->[0]-1,$pt->[0]+1)),
            (map { [$pt->[0],$_] } grep { $_ >= 0 && $_ <= $max_x }($pt->[1]-1,$pt->[1]+1)),
        );
        scalar(@compare) == scalar(grep { $map[$pt->[0]][$pt->[1]] < $map[$_->[0]][$_->[1]] } @compare);
    } map { my $y = $_; map { [$y,$_] } (0..$max_x) } (0..$max_y)
) . "\n";

