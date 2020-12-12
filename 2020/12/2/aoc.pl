#!/usr/bin/env perl

use strict;
use warnings;

my $x = 0;
my $y = 0;
my $dx = 10;
my $dy = -1;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^(\w)(\d+)$/) {
        move($1, $2);
    }
    else {
        die "Unexpected line: $line";
    }
}

print abs($x) + abs($y) . "\n";

sub move {
    my ($c, $n) = @_;

    if ($c eq 'N') {
        $dy -= $n;
    }
    elsif ($c eq 'S') {
        $dy += $n;
    }
    elsif ($c eq 'E') {
        $dx += $n;
    }
    elsif ($c eq 'W') {
        $dx -= $n;
    }
    elsif ($c eq 'L') {
        my $n1 = ($n / 90);
        do {
            my $tmp = $dx;
            $dx = $dy;
            $dy = -$tmp;
        } while (--$n1 > 0);
    }
    elsif ($c eq 'R') {
        my $n1 = ($n / 90);
        do {
            my $tmp = $dx;
            $dx = -$dy;
            $dy = $tmp;
        } while (--$n1 > 0);
    }
    elsif ($c eq 'F') {
        $x += $n * $dx;
        $y += $n * $dy;
    }
    else {
        die "Unexpected char: $c";
    }
}
