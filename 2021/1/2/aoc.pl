#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $prev;
my $res = 0;
my @a = map { chomp; $_ } <>;
my @b = map { sum(map { $a[$_] } ($_..$_+2)) } (0..$#a-2);
for my $x (@b) {
    $res++ if defined $prev && $x > $prev;
    $prev = $x;
}

print $res . "\n";
