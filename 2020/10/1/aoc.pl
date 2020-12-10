#!/usr/bin/env perl

use strict;
use warnings;

my @jolts = sort { $a <=> $b } map { chomp; $_ } <>;

push @jolts, $jolts[-1] + 3;
unshift @jolts, 0;

my %h;
$h{$_}++ foreach map { $jolts[$_+1] - $jolts[$_] } (0..$#jolts-1);
print $h{1} * $h{3} . "\n";
