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

my @oxy = @nums;
my @co2 = @nums;
while ($x--) {
    my $mask = 1 << $x;

    if (@oxy > 1) {
        my @a = grep { $_ & $mask } @oxy;
        my @b = grep { !($_ & $mask) } @oxy;
        if (scalar(@a) >= scalar(@b)) {
            @oxy = @a;
        }
        else {
            @oxy = @b;
        }
    }

    if (@co2 > 1) {
        my @a = grep { $_ & $mask } @co2;
        my @b = grep { !($_ & $mask) } @co2;
        if (scalar(@a) < scalar(@b)) {
            @co2 = @a;
        }
        else {
            @co2 = @b;
        }
    }
}

die unless scalar(@oxy) == 1 && scalar(@co2) == 1;

print $oxy[0] * $co2[0] . "\n";
