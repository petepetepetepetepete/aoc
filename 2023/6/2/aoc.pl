#!/usr/bin/env perl

use strict;
use warnings;

my ($time, $distance) = map { chomp; $_ } <>;

$time =~ s/Time: *//;
$distance =~ s/Distance: *//;

$time =~ s/ *//g;
$distance =~ s/ *//g;

my $count = 0;
for my $i (0..$time) {
    $count++ if winner($i, $time, $distance);
}

print $count . "\n";

sub winner {
    my ($t, $mt, $d) = @_;
    return $t * ($mt - $t) > $d;
}
