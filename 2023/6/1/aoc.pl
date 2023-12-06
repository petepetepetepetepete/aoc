#!/usr/bin/env perl

use strict;
use warnings;

my ($time, $distance) = map { chomp; $_ } <>;

$time =~ s/Time: *//;
$distance =~ s/Distance: *//;

my @times = split / +/, $time;
my @distances = split / +/, $distance;

my $result = 1;
for my $i (0..$#times) {
    my $count = 0;
    for my $j (0..$times[$i]) {
        $count++ if winner($j, $times[$i], $distances[$i]);
    }
    $result *= $count;
}

print $result . "\n";

sub winner {
    my ($t, $mt, $d) = @_;
    return $t * ($mt - $t) > $d;
}
