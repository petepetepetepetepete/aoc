#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my (@a, %b);
for my $x (map { chomp; [split /\s+/] } <>) {
    push @a, $x->[0];
    $b{$x->[1]}++;
}

print sum(map { $_ * ($b{$_} // 0) } @a) . "\n";
