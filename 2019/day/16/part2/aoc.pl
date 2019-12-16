#!/usr/bin/env perl

use strict;
use warnings;

chomp(my $input = <STDIN>);
$input = $input x 10000;
my @input = split //, $input;
my $offset = int(join('', @input[0..6]));

for my $x (1..100) {
    my $x = $input[-1];
    for (my $i = $#input; $i >= $offset; $i--) {
        $input[$i] = $x;
        $x = ($input[$i] + $input[$i-1]) % 10;
    }
}

print join('', @input[$offset..$offset+7]) . "\n";

