#!/usr/bin/env perl

use strict;

use List::Util qw/all min max sum/;

my $mult = shift;
my @g = map { chomp; [ split //, $_ ] } <>;

my $max_y = $#g;
my $max_x = $#{$g[0]};

my %row_mult = map { my $y=$_; $y => (all { $g[$y][$_] eq '.' } (0..$max_x)) ? $mult : 1 } (0..$max_y);
my %col_mult = map { my $x=$_; $x => (all { $g[$_][$x] eq '.' } (0..$max_y)) ? $mult : 1 } (0..$max_x);

my @pts = grep { my ($x,$y)=@$_; $g[$y][$x] eq '#' } map { my $y=$_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);

my $result = 0;
for my $i (0..$#pts) {
    for my $j ($i+1..$#pts) {
        my $min_x = min($pts[$i][0], $pts[$j][0]);
        my $max_x = max($pts[$i][0], $pts[$j][0]);
        my $min_y = min($pts[$i][1], $pts[$j][1]);
        my $max_y = max($pts[$i][1], $pts[$j][1]);
        $result += sum(map { $col_mult{$_} } ($min_x+1..$max_x)) // 0;
        $result += sum(map { $row_mult{$_} } ($min_y+1..$max_y)) // 0;
    }
}

print $result . "\n";

