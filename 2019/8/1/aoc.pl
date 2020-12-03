#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/reduce/;

my ($w, $t) = @ARGV;
my $area = $w * $t;

chomp(my $input = <STDIN>);
my @pixels = split //, $input;

my @layers;
while (scalar(@pixels)) {
    push @layers, [splice @pixels, 0, $area];
}

my $min_layer;
my @zeroes = map { scalar(grep { $_ == 0 } @{$layers[$_]})  } (0..$#layers);
my $layer = reduce { $zeroes[$a] < $zeroes[$b] ? $a : $b } (0..$#zeroes);

printf "%d\n", scalar(grep { $_ == 1 } @{$layers[$layer]}) * scalar(grep { $_ == 2 } @{$layers[$layer]});

