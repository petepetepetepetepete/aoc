#!/usr/bin/env perl

use strict;
use warnings;

my %cubes = (
    red => 12,
    green => 13,
    blue => 14,
);

my $result = 0;
OUTER:
while (my $line = <>) {
    chomp $line;
    my ($a, $b) = split /: /, $line;
    my ($id) = $a =~ m/^Game (\d+)$/;
    my @turns = split /; /, $b;

    for my $x (map { split /, /, $_ } @turns) {
        my ($num, $colour) = split / /, $x;
        #warn "$num $colour";
        next OUTER if $num > $cubes{$colour};
    }

    $result += $id;
}

print $result . "\n";
