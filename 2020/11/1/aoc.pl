#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;

my @map = map { chomp; [ split // ]} <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};

sub tick {
    my $tmp = dclone \@map;

    for my $y (0..$max_y) {
        for my $x (0..$max_x) {
            if ($tmp->[$y][$x] eq 'L' && adjacent_occupied($x, $y, $tmp) == 0) {
                $map[$y][$x] = '#';
            }
            elsif ($tmp->[$y][$x] eq '#' && adjacent_occupied($x, $y, $tmp) >= 4) {
                $map[$y][$x] = 'L';
            }
        }
    }
}

my $last = -1;
while (1) {
    tick();
    my $occupied = scalar(grep { $_ eq '#' } map { @$_ } @map);
    last if $last == $occupied;
    $last = $occupied;
}

print $last . "\n";

sub adjacent_occupied {
    my ($x, $y, $m) = @_;

    my $occupied = 0;
    for my $j ($y-1..$y+1) {
        next if $j < 0 || $j > $max_y;
        for my $i ($x-1..$x+1) {
            next if $i < 0 || $i > $max_x || ($i == $x && $j == $y);
            $occupied++ if $m->[$j][$i] eq '#';
        }
    }

    return $occupied;
}
