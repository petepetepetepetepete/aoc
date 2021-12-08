#!/usr/bin/env perl

use strict;
use warnings;

my $res = 0;
while (my $line = <>) {
    chomp $line;
    my @a = split / \| /, $line;
    my @signal = split / /, $a[0];
    my @output = split / /, $a[1];
    $res += scalar(grep { length($_) == 2 || length($_) == 4 || length($_) == 3 || length($_) == 7 } @output);
}

print $res . "\n";
