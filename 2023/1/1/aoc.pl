#!/usr/bin/env perl

use strict;
use warnings;

my $result = 0;
while (my $line = <>) {
    chomp $line;
    my ($a, $b);
    if ($line =~ m/^[^\d]*(\d).*(\d)/) {
        ($a, $b) = ($1, $2);
    }
    elsif ($line =~ m/^[^\d]*(\d)/) {
        ($a, $b) = ($1, $1);
    }
    else {
        die "$line does not contain a digit";
    }

    $result += 10 * $a + $b;
}

print $result . "\n";

