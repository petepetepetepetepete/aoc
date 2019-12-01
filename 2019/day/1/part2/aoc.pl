#!/usr/bin/env perl

use strict;
use warnings;

sub fuel {
    my $mass = shift;

    my $fuel = int($mass/3) - 2;
    return 0 unless $fuel > 0;

    return $fuel + fuel($fuel);
}

my $fuel = 0;
while (my $mass = <>) {
    chomp $mass;
    $fuel += fuel($mass);
}

print $fuel . "\n";
