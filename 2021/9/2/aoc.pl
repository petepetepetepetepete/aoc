#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/all product/;

my @map = map { chomp; [ split // ] } <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};

my @basins = map { my $y = $_; map { basin([$y,$_]) } (0..$max_x) } (0..$max_y);
print product((sort { $b <=> $a } map { scalar(@{$_}) } @basins)[0..2]) . "\n";

sub basin {
    my $start = shift;
    my @res;
    my @pts = ($start);

    while (my $pt = shift @pts) {
        next if $map[$pt->[0]][$pt->[1]] >= 9;
        my @compare = grep {
            my $pt2 = $_;
            !grep { $_->[0] == $pt2->[0] && $_->[1] == $pt2->[1] } @res;
        } (
            (map { [$_,$pt->[1]] } grep { $_ >= 0 && $_ <= $max_y } ($pt->[0]-1,$pt->[0]+1)),
            (map { [$pt->[0],$_] } grep { $_ >= 0 && $_ <= $max_x } ($pt->[1]-1,$pt->[1]+1)),
        );

        if (all { $map[$pt->[0]][$pt->[1]] <= $map[$_->[0]][$_->[1]] } @compare) {
            push @pts, @compare;
            push @res, $pt unless grep { $pt->[0] == $_->[0] && $pt->[1] == $_->[1] } @res;
        }
    }

    return [@res] if scalar(@res);
    return;
}
