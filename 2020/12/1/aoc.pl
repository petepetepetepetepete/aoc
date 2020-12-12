#!/usr/bin/env perl

use strict;
use warnings;

my @dirs = qw/N E S W/;
my $dir = 1;
my $x = 0;
my $y = 0;
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
        $y -= $n;
    }
    elsif ($c eq 'S') {
        $y += $n;
    }
    elsif ($c eq 'E') {
        $x += $n;
    }
    elsif ($c eq 'W') {
        $x -= $n;
    }
    elsif ($c eq 'L') {
        $dir = ($dir - ($n / 90)) % scalar(@dirs);
    }
    elsif ($c eq 'R') {
        $dir = ($dir + ($n / 90)) % scalar(@dirs);
    }
    elsif ($c eq 'F') {
        move($dirs[$dir], $n);
    }
    else {
        die "Unexpected char: $c";
    }
}
