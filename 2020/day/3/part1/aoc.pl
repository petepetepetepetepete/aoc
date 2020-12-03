#!/usr/bin/env perl

use strict;
use warnings;

my ($dx, $dy) = (3, 1);
my $max_x = 0;
my @map;
while (my $line = <>) {
    chomp $line;
    my @c = split //, $line;
    $max_x ||= scalar(@c);
    push @map, \@c;
}

my @coords = map { [ $_ * $dy, ($_ * $dx) % $max_x ] } (0..$#map);
my @trees = grep { my ($y, $x) = @{$_}; $map[$y][$x] eq '#' } @coords;

print scalar(@trees) . "\n";

