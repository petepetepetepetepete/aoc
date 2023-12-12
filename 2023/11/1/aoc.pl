#!/usr/bin/env perl

use strict;
use warnings;

use Algorithm::Combinatorics qw/combinations/;
use List::Util qw/all sum/;

my @g = map { chomp; [ split //, $_ ] } <>;

my $max_y = $#g;
my $max_x = $#{$g[0]};

my @empty_row = grep { my $y=$_; all { $g[$y][$_] eq '.' } (0..$max_x) } (reverse 0..$max_y);
my @empty_col = grep { my $x=$_; all { $g[$_][$x] eq '.' } (0..$max_y) } (reverse 0..$max_x);

for my $i (@empty_row) {
    splice(@g, $i, 0, [ map { '.' } (0..$max_x) ]);
}
$max_y = $#g;

for my $i (@empty_col) {
    for my $j (0..$max_y) {
        splice(@{$g[$j]}, $i, 0, '.');
    }
}
$max_x = $#{$g[0]};

my @pts = grep { my ($x,$y)=@$_; $g[$y][$x] eq '#' } map { my $y=$_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);

my $result = 0;
my $iter = combinations(\@pts, 2);
while (my $c = $iter->next) {
    my ($a, $b) = @$c;
    $result += sum(map { abs($a->[$_] - $b->[$_]) } (0..1));
}

print $result . "\n";

