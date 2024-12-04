#!/usr/bin/env perl

use strict;
use warnings;

my $in = do { local $/; <> };
my $res = 0;
my $enabled = 1;
while ($in =~ m/(do)\(\)|(don't)\(\)|mul\((\d{1,3}),(\d{1,3})\)/g) {
    if ($1 && $1 eq q/do/) { $enabled++ }
    elsif ($2 && $2 eq q/don't/) { $enabled = 0 }
    elsif ($enabled) { $res += $3 * $4 }
}

print $res . "\n";
