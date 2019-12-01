#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

print sum(map { fuel($_) } <>) . "\n";

sub fuel {
    my $mass = shift;

    my $fuel = int($mass/3) - 2;
    return 0 unless $fuel > 0;

    return $fuel + fuel($fuel);
}

