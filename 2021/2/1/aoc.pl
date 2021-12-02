#!/usr/bin/env perl

use strict;
use warnings;

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
    }
    elsif ($dir eq 'down') {
        $z += $n;
    }
    elsif ($dir eq 'up') {
        $z -= $n;
    }
    else {
        die "Unexpected direction: $dir";
    }
}

print $x * $z . "\n";
