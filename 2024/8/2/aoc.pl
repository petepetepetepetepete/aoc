#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min sum/;

my %c;
my @grid = map { chomp; my @c = split //; $c{$_}++ foreach grep { m/[0-9A-Za-z]/ } @c; [ @c ] } <>;
my $max_y = $#grid;
my $max_x = $#{$grid[0]};

my %res;
$res{$_}++ foreach map { antinodes(\@grid, $_) } keys %c;
print scalar(keys %res) . "\n";

sub antinodes {
    my ($g, $c) = @_;

    my @a = grep { $g->[$_->[1]][$_->[0]] eq $c } map { my $y = $_; map { [$_,$y] } (0..$max_x) } (0..$max_y);

    my %res;

    for my $i (0..$#a) {
        my $k = join(',', @{$a[$i]});
        $res{$k}++;
        for my $j ($i+1..$#a) {
            my ($a1,$a2) = map { $a[$_] } sort { min($a[$i][0],$a[$j][0]) || min($a[$i][1],$a[$j][1]) } ($i, $j);

            my $rise = $a2->[1] - $a1->[1];
            my $run = $a2->[0] - $a1->[0];

            my ($x, $y) = ($a1->[0] - $run, $a1->[1] - $rise);
            while ($x >= 0 && $x <= $max_x && $y >= 0 && $y <= $max_y) {
                $res{"$x,$y"}++;
                $x -= $run;
                $y -= $rise;
            }

            ($x, $y) = ($a2->[0] + $run, $a2->[1] + $rise);
            while ($x >= 0 && $x <= $max_x && $y >= 0 && $y <= $max_y) {
                $res{"$x,$y"}++;
                $x += $run;
                $y += $rise;
            }
        }
    }

    return keys %res;
}
