#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;

my @dirs = grep { $_->[0] != 0 || $_->[1] != 0 } map { my $x = $_; map { [ $x, $_ ] } (-1..1); } (-1..1);
my @map = map { chomp; [ split // ]} <>;
my $max_y = $#map;
my $max_x = $#{$map[0]};

sub tick {
    my $tmp = dclone \@map;

    for my $y (0..$max_y) {
        for my $x (0..$max_x) {
            if ($tmp->[$y][$x] =~ m/^([L#])$/) {
                my $c = $1;
                my $occupied = adjacent_occupied($x, $y, $tmp);

                if ($c eq 'L' && $occupied == 0) {
                    $map[$y][$x] = '#';
                }
                elsif ($c eq '#' && $occupied >= 5) {
                    $map[$y][$x] = 'L';
                }
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
    for my $dir (@dirs) {
        my $x1 = $x + $dir->[0];
        my $y1 = $y + $dir->[1];
        while ($x1 >= 0 && $x1 <= $max_x && $y1 >= 0 && $y1 <= $max_x) {
            if ($m->[$y1][$x1] =~ m/([#L])/) {
                $occupied++ if $1 eq '#';
                last;
            }

            $x1 += $dir->[0];
            $y1 += $dir->[1];
        }
    }

    return $occupied;
}
