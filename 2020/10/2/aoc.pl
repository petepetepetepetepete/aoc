#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min/;

my @jolts = sort { $a <=> $b } map { chomp; $_ } <>;

push @jolts, $jolts[-1] + 3;
unshift @jolts, 0;

my @s = grep { $jolts[$_+1] - $jolts[$_-1] <= 3 } (1..$#jolts-1);
my $res = 1;
for (my $i = 0; $i <= $#s; $i++) {
    if ($i <= $#s - 2 && $s[$i+2] - $s[$i] == 2) {
        $res *= 7;
        $i += 2;
    }
    elsif ($i <= $#s - 1 && $s[$i+1] - $s[$i] == 1) {
        if ($jolts[$s[$i]+2] - $jolts[$s[$i]-1] > 3) {
            $res *= 3;
        }
        else {
            $res *= 4;
        }
        $i++;
    }
    else {
        $res *= 2;
    }
}

print $res . "\n";
