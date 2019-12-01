#!/usr/bin/env perl

use strict;
use warnings;

my $fuel = 0;
while (my $mass = <>) {
    chomp $mass;
    $fuel += int($mass / 3) - 2;
}

print $fuel . "\n";
