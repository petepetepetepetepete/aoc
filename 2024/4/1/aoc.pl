#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @grid = map { chomp; [ split // ] } <>;
my $max_y = $#grid;
my $max_x = $#{$grid[0]};
my @needle = split //, 'XMAS';
my @dirs = grep { $_->[0] != 0 || $_->[1] != 0  } map { my $i=$_; map { [$i,$_] } (-1..1)  } (-1..1);

print sum(map { my $y = $_; map { my $x = $_; map { count_xmas($x, $y, $_, @needle) } @dirs } (0..$max_x) } (0..$max_y)) . "\n";

sub count_xmas {
    my ($x, $y, $dir, $c, @rem) = @_;
    return 0 if $x < 0 or $x > $max_x;
    return 0 if $y < 0 or $y > $max_y;
    return 0 if $grid[$y][$x] ne $c;
    return 1 unless @rem;

    return count_xmas($x+$dir->[0], $y+$dir->[1], $dir, @rem);
}

