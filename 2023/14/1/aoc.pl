#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @m = map { chomp; [ split //, $_ ] } <>;

my $max_y = $#m;
my $max_x = $#{$m[0]};

my $m = join("\n", map { my $y = $_; join('', map { $m[$y][$_] } (0..$max_x)) } (0..$max_y));
my $pm = '';

while ($m ne $pm) {
    for my $y (1..$max_y) {
        for my $x (grep { $m[$y][$_] eq 'O' } (0..$max_x)) {
            if ($m[$y-1][$x] eq '.') {
                $m[$y-1][$x] = 'O';
                $m[$y][$x] = '.';
            }
        }
    }

    $pm = $m;
    $m = join("\n", map { my $y = $_; join('', map { $m[$y][$_] } (0..$max_x)) } (0..$max_y));
}

print sum(
    map {
        my $y = $_;
        my @o = grep { $m[$y][$_] eq 'O' } (0..$max_x);
        ($max_y - $y + 1) * @o
    } (0..$max_y)
) . "\n";
