#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/all sum/;

print sum(map { chomp; solve(split / /, $_) } <>) . "\n";

sub solve {
    my @n = @_;

    my @x = extrapolate([@n]);
    return $x[0]->[0];
}

sub extrapolate {
    my @n = @_;

    my $i = $#n;
    my @x = @{$n[$i]};
    return (@n, 0) if all { $_ == 0 } @x;

    push @n, [ map { $x[$_+1] - $x[$_] } (0..$#x-1) ];

    my @r = extrapolate(@n);
    unshift @{$r[$i]}, $r[$i]->[0] - $r[$i+1]->[0];

    return @r;
}

