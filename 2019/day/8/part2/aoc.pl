#!/usr/bin/env perl

use strict;
use warnings;

use Term::ANSIColor;

my ($w, $t) = @ARGV;
my $area = $w * $t;

chomp(my $input = <STDIN>);
my @pixels = split //, $input;

my @layers;
while (scalar(@pixels)) {
    push @layers, [splice @pixels, 0, $area];
}

my @image;
for my $layer (reverse(0..$#layers)) {
    for my $i (0..$area-1) {
        my $color = $layers[$layer][$i];
        $image[$i] = $color unless $color == 2;
    }
}

for my $i (0..$#image) {
    printf '%s█', $image[$i] ? color('white') : color('black');
    print "\n" if $i % $w == $w - 1;
}

print color('reset');

