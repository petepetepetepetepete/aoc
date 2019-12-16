#!/usr/bin/env perl

use strict;
use warnings;

my @base = (0, 1, 0, -1);
chomp(my $input = <STDIN>);
my @input = split //, $input;

for my $x (1..100) {
    my @res;
    for my $i (0..$#input) {
        my @pattern = map { my $x = $_; map { $x } (0..$i) } @base;
        my $pat_len = scalar(@pattern);
        my $idx = 0;
        my $digit = 0;
        for my $j (0..$#input) {
            $digit += $input[$j] * $pattern[++$idx % $pat_len];
        }

        push @res, abs($digit) % 10;
    }

    @input = @res;
}

print join('', @input[0..7]) . "\n";
