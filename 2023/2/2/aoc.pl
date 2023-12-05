#!/usr/bin/env perl

use strict;
use warnings;

my @colours = qw/red green blue/;

my $result = 0;
while (my $line = <>) {
    chomp $line;
    my ($a, $b) = split /: /, $line;
    my ($id) = $a =~ m/^Game (\d+)$/;
    my @turns = split /; /, $b;

    my %x;
    for my $x (map { split /, /, $_ } @turns) {
        my ($num, $colour) = split / /, $x;
        #warn "$num $colour";
        $x{$colour} //= $num;
        $x{$colour} = $num if $num > ($x{$colour} // 0);
    }
    my $power = 1;
    $power *= $x{$_} foreach @colours;

    $result += $power;
}

print $result . "\n";
