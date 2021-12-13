#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max sum/;

my @map;
my $max_x = 0;
my $max_y = 0;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^(\d+),(\d+)$/) {
        $map[$2][$1] = 1;
        $max_x = max($max_x, $1);
        $max_y = max($max_y, $2);
    }
    elsif ($line =~ m/^fold along ([xy])=(\d+)$/) {
        if ($1 eq 'x') {
            @map = map { my $y = $_; [ map { ($map[$y][$_] // 0) | ($map[$y][$max_x-$_] // 0) } (0..$2-1) ] } (0..$max_x);
            $max_x = $2-1;
        }
        elsif ($1 eq 'y') {
            @map = map { my $y = $_; [ map { ($map[$y][$_] // 0) | ($map[$max_y-$y][$_] // 0) } (0..$max_x) ] } (0..$2-1);
            $max_y = $2-1;
        }
    }
    elsif ($line ne '') {
        warn "Unexpected line: $line";
    }
}

print join "\n", map { my $y = $_; join '', map { $map[$y][$_] ? '#' : '.' } (0..$max_x) } (0..$max_y);
print "\n";
