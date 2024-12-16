#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/first sum/;

my ($map, $movements) = do { local $/; split /\n\n/, <>};
$movements =~ s/\n//g;

my @map = map { [ split // ] } split /\n/, $map;
my $max_y = $#map;
my $max_x = $#{$map[0]};
my ($robot) = grep { $map[$_->[1]][$_->[0]] eq '@' } map { my $y=$_; map { [$_,$y] } (0..$max_x) } (0..$max_y);
$map[$robot->[1]][$robot->[0]] = '.';

for my $step (split //, $movements) {
    #warn "Move $step\n";
    my ($x,$y) = @$robot;

    if ($step eq '^') {
        my @above = reverse(0..$y-1);
        my $first_empty = first { $map[$_][$x] eq '.' } @above;
        if (defined $first_empty) {
            my $first_wall = first { $map[$_][$x] eq '#' } @above;
            if ($first_wall < $first_empty) {
                for (my $i = $first_empty; $i < $y; $i++) {
                    $map[$i][$x] = $map[$i+1][$x];
                }
                $robot->[1]--;
            }
        }
    }
    elsif ($step eq 'v') {
        my @below = ($y+1..$max_y);
        my $first_empty = first { $map[$_][$x] eq '.' } @below;
        if (defined $first_empty) {
            my $first_wall = first { $map[$_][$x] eq '#' } @below;
            if ($first_wall > $first_empty) {
                for (my $i = $first_empty; $i > $y; $i--) {
                    $map[$i][$x] = $map[$i-1][$x];
                }
                $robot->[1]++;
            }
        }
    }
    elsif ($step eq '<') {
        my @left = reverse(0..$x-1);
        my $first_empty = first { $map[$y][$_] eq '.' } @left;
        if (defined $first_empty) {
            my $first_wall = first { $map[$y][$_] eq '#' } @left;
            if ($first_wall < $first_empty) {
                for (my $i = $first_empty; $i < $x; $i++) {
                    $map[$y][$i] = $map[$y][$i+1];
                }
                $robot->[0]--;
            }
        }
    }
    elsif ($step eq '>') {
        my @right = ($x+1..$max_x);
        my $first_empty = first { $map[$y][$_] eq '.' } @right;
        if (defined $first_empty) {
            my $first_wall = first { $map[$y][$_] eq '#' } @right;
            if ($first_wall > $first_empty) {
                for (my $i = $first_empty; $i > $x; $i--) {
                    $map[$y][$i] = $map[$y][$i-1];
                }
                $robot->[0]++;
            }
        }
    }
    else {
        die "Unexpected character: $step";
    }

    #warn join("\n", map { my $y=$_; join('', map { ($_ == $robot->[0] && $y == $robot->[1]) ? '@' : $map[$y][$_] } (0..$max_x)) } (0..$max_y));
    #warn "\n";
}

print sum(map { my $y=$_; map { $map[$y][$_] eq 'O' ? 100 * $y + $_ : 0 } (0..$max_x) } (0..$max_y)) . "\n";
