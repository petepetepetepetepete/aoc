#!/usr/bin/env perl

use strict;
use warnings;

my @a;
while (my $line = <>) {
    chomp $line;

    push @a, $line;
}

for my $a (@a) {
    for my $b (@a) {
        for my $c (@a) {
            if ($a + $b + $c == 2020) {
                print $a * $b * $c . "\n";
                exit;
            }
        }
    }
}
