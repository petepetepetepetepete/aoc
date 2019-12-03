#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min/;

my %map;
my $wire = 0;
my $min_dist = 999_999_999;

while (my $line = <>) {
    chomp $line;
    my ($x, $y) = (0, 0);

    for my $instr (split /,/, $line) {
        my ($dir, $steps) = $instr =~ m/([LRUD])(\d+)/;

        my @xs = ($x);
        my @ys = ($y);
        if ($dir eq 'L') {
            @xs = reverse($x-$steps .. $x);
            $x -= $steps;
        }
        elsif ($dir eq 'R') {
            @xs = ($x .. $x+$steps);
            $x += $steps;
        }
        elsif ($dir eq 'U') {
            @ys = reverse($y-$steps .. $y);
            $y -= $steps;
        }
        elsif ($dir eq 'D') {
            @ys = ($y .. $y+$steps);
            $y += $steps;
        }
        else {
            die "Invalid direction: $dir";
        }

        for my $i (@ys) {
            for my $j (@xs) {
                if ($wire) {
                    if (defined $map{$i}{$j} && ($i != 0 || $j != 0)) {
                        $min_dist = min($min_dist, abs($i) + abs($j));
                    }
                }
                else {
                    $map{$i}{$j} = '.';
                }
            }
        }
    }

    $wire++;
}

print "$min_dist\n";
