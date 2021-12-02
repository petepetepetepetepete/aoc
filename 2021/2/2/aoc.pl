#!/usr/bin/env perl

use strict;
use warnings;

my $aim = 0;
my $x = 0;
my $z = 0;

while (my $line = <>) {
    chomp $line;
    my $dir;
    my $n;
    if ($line =~ m/^(\w+) (\d+)$/) {
        ($dir, $n) = ($1, $2);
    }
    else {
        die "Unexpected input: $line";
    }

    if ($dir eq 'forward') {
        $x += $n;
        $z += ($aim * $n);
    }
    elsif ($dir eq 'down') {
        $aim += $n;
    }
    elsif ($dir eq 'up') {
        $aim -= $n;
    }
    else {
        die "Unexpected direction: $dir";
    }
}

print $x * $z . "\n";
