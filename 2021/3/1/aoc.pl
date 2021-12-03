#!/usr/bin/env perl

use strict;
use warnings;

my @nums;
my $x;
while (my $line = <>) {
    chomp $line;
    $x //= length($line);
    push @nums, oct("0b$line");
}

my $gamma = 0;
my $epsilon = 0;
while ($x--) {
    my $mask = 1 << $x;

    $epsilon <<= 1;
    $gamma <<= 1;

    if (scalar(grep { $_ & $mask } @nums) > scalar(@nums) / 2) {
        $gamma++;
    }
    else {
        $epsilon++;
    }
}

print $gamma * $epsilon . "\n";

