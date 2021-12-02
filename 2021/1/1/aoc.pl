#!/usr/bin/env perl

use strict;
use warnings;

my $prev;
my $res = 0;
while (my $line = <>) {
    chomp $line;
    $res++ if defined $prev && $line > $prev;
    $prev = $line;
}

print $res . "\n";
