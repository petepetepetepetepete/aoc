#!/usr/bin/env perl

use strict;
use warnings;

my $match_count = 0;
while (my $line = <>) {
    if ($line =~ m/^(\d+)-(\d+) ([a-z]): ([a-z]+)$/) {
        my ($a, $b, $c, $p) = ($1, $2, $3, $4);
        my @matches = grep { $_ eq $c } split //, $p;
        if (scalar(@matches) >= $a && scalar(@matches) <= $b) {
            $match_count++;
        }
    }
    else {
        die "Unexpected input: $line";
    }

}

print $match_count . "\n";
