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

    my $dist = 0;
    for my $instr (split /,/, $line) {
        my ($dir, $steps) = $instr =~ m/([LRUD])(\d+)/;

        my @xs = ($x);
        my @ys = ($y);
        if ($dir eq 'L') {
            @xs = reverse($x-$steps .. $x-1);
            $x -= $steps;
        }
        elsif ($dir eq 'R') {
            @xs = ($x+1 .. $x+$steps);
            $x += $steps;
        }
        elsif ($dir eq 'U') {
            @ys = reverse($y-$steps .. $y-1);
            $y -= $steps;
        }
        elsif ($dir eq 'D') {
            @ys = ($y+1 .. $y+$steps);
            $y += $steps;
        }
        else {
            die "Invalid direction: $dir";
        }

        for my $i (@ys) {
            for my $j (@xs) {
                if ($wire) {
                    $dist++;
                    if (defined $map{$i}{$j} && ($i != 0 || $j != 0)) {
                        $min_dist = min($min_dist, $dist + $map{$i}{$j});
                    }
                }
                else {
                    $map{$i}{$j} = ++$dist;
                }
            }
        }
    }

    $wire++;
}

print "$min_dist\n";
