#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;
use Tie::Array::Sorted;

tie my @a, 'Tie::Array::Sorted';
tie my @b, 'Tie::Array::Sorted';

for my $x (map { chomp; [split /\s+/] } <>) {
    push @a, $x->[0];
    push @b, $x->[1];
}

print sum(map { abs($a[$_]-$b[$_]) } (0..$#a)) . "\n";

