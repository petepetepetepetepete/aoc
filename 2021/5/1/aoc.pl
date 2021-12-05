#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min max/;

my @lines;
my %map;
while (my $line = <>) {
    chomp $line;
    my ($x1,$x2,$y1,$y2);
    if ($line =~ m/(\d+),(\d+) -> (\d+),(\d+)/) {
        ($x1,$y1,$x2,$y2) = ($1,$2,$3,$4);
    }
    else {
        die "Unexpected line: $line";
    }

    if ($x1 == $x2) {
        for my $y (min($y1,$y2)..max($y1,$y2)) {
            $map{$y}{$x1}++;
        }
    }
    elsif ($y1 == $y2) {
        for my $x (min($x1,$x2)..max($x1,$x2)) {
            $map{$y1}{$x}++;
        }
    }
}

my $res = 0;
for my $y (sort keys %map) {
    for my $x (sort keys %{$map{$y}}) {
        if ($map{$y}{$x} > 1) {
            $res++;
        }
    }
}

print $res . "\n";
