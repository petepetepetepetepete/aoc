#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @fish = map { 0 } (0..9);;
my $line = <>;
chomp $line;
$fish[$_]++ foreach split /,/, $line;

for my $i (1..80) {
    my $x = $fish[0];
    for my $j (1..8) {
        $fish[$j-1] = $fish[$j];
    }
    $fish[8] = $x;
    $fish[6] += $x;
}

print sum(@fish) . "\n";
