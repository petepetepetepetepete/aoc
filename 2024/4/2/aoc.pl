#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @grid = map { chomp; [ split // ] } <>;
my $max_y = $#grid;
my $max_x = $#{$grid[0]};
my %opp = ('M' => 'S', 'S' => 'M');

print sum(map { my $y = $_; map { count_cross_mas($_, $y) } (0..$max_x-2) } (0..$max_y-2)) . "\n";

sub count_cross_mas {
    my ($x, $y) = @_;
    return 0 if $grid[$y+1][$x+1] ne 'A';
    return 0 if $grid[$y][$x] !~ m/^([MS])$/;
    return 0 if $grid[$y+2][$x+2] ne $opp{$1};
    return 0 if $grid[$y][$x+2] !~ m/^([MS])$/;
    return 0 if $grid[$y+2][$x] ne $opp{$1};

    return 1;
}

