#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max/;

my $ts = <>;
chomp $ts;
my $b = <>;
chomp $b;
my @buses = grep { $_ ne 'x' } split /,/, $b;

for my $i ($ts..$ts+max(@buses)) {
    my @stops = grep { $i % $_ == 0 } @buses;
    if (@stops) {
        print $stops[0] * ($i-$ts) . "\n";
        last;
    }
}
