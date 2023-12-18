#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max/;

my @m = (['#']);
my @plan = map { chomp; [ split / /, $_ ] } <>;

my ($x,$y) = (0,0);
my $max_x = 0;
my $max_y = 0;

for my $step (@plan) {
    my ($dir, $len, $rgb) = @$step;

    if ($dir eq 'R') {
        my $diff = $x + $len - $max_x;
        if ($diff > 0) {
            for my $i (0..$max_y) {
                push @{$m[$i]}, map { '.' } (1..$diff);
            }
        }
        for my $i (1..$len) {
            $m[$y][$x+$i] = '#';
        }

        $x += $len;
    }
    elsif ($dir eq 'L') {
        my $diff = $len - $x;
        if ($diff > 0) {
            for my $i (0..$max_y) {
                unshift @{$m[$i]}, map { '.' } (1..$diff);
            }

            $x += $diff;
        }

        for my $i (1..$len) {
            $m[$y][$x-$i] = '#';
        }

        $x -= $len;
    }
    elsif ($dir eq 'U') {
        my $diff = $len - $y;
        if ($diff > 0) {
            unshift @m, [ map { '.' } (0..$max_x) ] foreach (1..$diff);
            $y += $diff;
        }

        for my $i (1..$len) {
            $m[$y-$i][$x] = '#';
        }

        $y -= $len;
    }
    elsif ($dir eq 'D') {
        my $diff = $y + $len - $max_y;
        if ($diff > 0) {
            push @m, [ map { '.' } (0..$max_x) ] foreach (1..$diff);
        }

        for my $i (1..$len) {
            $m[$y+$i][$x] = '#';
        }

        $y += $len;
    }
    else {
        die "Unexpected dir: $dir";
    }

    $max_y = $#m;
    $max_x = $#{$m[0]};
}

# find a point to start spilling
$y = 1;
for my $i (0..$max_x) {
    if ($m[$y][$i] eq '#' && $m[$y][$i+1] eq '.') {
        $x = $i + 1;
        last;
    }
}
my @steps = [$x,$y];
while (my $step = shift @steps) {
    my ($x, $y) = @$step;
    $m[$y][$x] = '#';
    for my $pt ([1,0],[-1,0],[0,1],[0,-1]) {
        my $nx = $x + $pt->[0];
        my $ny = $y + $pt->[1];
        next if $nx < 0 or $nx > $max_x or $ny < 0 or $ny > $max_y;
        next if $m[$ny][$nx] ne '.';
        next if grep { $_->[0] eq $nx && $_->[1] eq $ny } @steps;

        push @steps, [$nx, $ny];
    }
}

print scalar(grep { $_ eq '#' } map { @$_ } @m) . "\n";

