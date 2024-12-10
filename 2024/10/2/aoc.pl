#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @map = map { chomp; [ split // ] } <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};
my @trail_heads = grep { $map[$_->[1]][$_->[0]] ne '.' && $map[$_->[1]][$_->[0]] == 0 } map { my $y = $_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);
my %memo;

print sum(map { score(@$_, 0) } @trail_heads) . "\n";

sub score {
    my ($x, $y, $height) = @_;
    return 1 if $height == 9;

    my @next = valid_steps($x, $y, $height);
    return 0 unless @next;
    return sum(map { score(@$_, $height+1) } @next);
}

sub valid_steps {
    my ($x, $y, $height) = @_;

    my $k = "$x,$y";
    if (!defined $memo{$k}) {
        my @dir = (
            [ -1, 0 ],
            [ 0, -1 ],
            [ 1, 0 ],
            [ 0, 1 ],
        );

        $memo{$k} = [ grep { $_->[0] >= 0 && $_->[0] <= $max_x && $_->[1] >= 0 && $_->[1] <= $max_y && $map[$_->[1]][$_->[0]] ne '.' && $map[$_->[1]][$_->[0]] == $height+1 } map { [$x+$_->[0], $y+$_->[1]] } @dir ];
    }
    return @{$memo{$k}};
}
