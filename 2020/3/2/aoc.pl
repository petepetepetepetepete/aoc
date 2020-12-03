#!/usr/bin/env perl

use strict;
use warnings;

my @slopes = (
    [1, 1],
    [3, 1],
    [5, 1],
    [7, 1],
    [1, 2],
);
my $max_x = 0;
my @map;
while (my $line = <>) {
    chomp $line;
    my @c = split //, $line;
    $max_x ||= scalar(@c);
    push @map, \@c;
}

my $n = 1;
for my $slope (@slopes) {
    my ($dx, $dy) = @$slope;
    my @coords = map { [ $_ * $dy, ($_ * $dx) % $max_x ] } (0..$#map);
    my @trees = grep { my ($y, $x) = @{$_}; $y < scalar(@map) && $map[$y][$x] eq '#' } @coords;
    $n *= scalar(@trees);
}

print $n . "\n";
