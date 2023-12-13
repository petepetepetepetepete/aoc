#!/usr/bin/env perl

use strict;
use warnings;

my $input = join '', <>;

use List::Util qw/sum/;

my @p;
my @rp;
for my $pattern (map { chomp; $_ } split /\n\n/, $input) {
    my @g = map { [ map { $_ eq '#' ? 1 : 0 } split //, $_ ] } split /\n/, $pattern;
    my @rg;

    # rotate
    for my $y (0..$#g) {
        for my $x (0..$#{$g[$y]}) {
            $rg[$x][$y] = $g[$y][$x];
        }
    }

    push @p, [ 100, [ map { oct('0b' . join('', @$_)) } @g ] ];
    push @p, [ 1, [ map { oct('0b' . join('', @$_)) } @rg ] ];
}

print sum (
    map {
        my ($m, $p) = @$_;
        map { $m*($_+1) } grep { mirror($_, $p) } grep { $p->[$_] == $p->[$_+1] } (0..$#$p-1);
    } @p
) . "\n";

sub mirror {
    my ($i, $p) = @_;

    for (my ($j, $k) = ($i-1, $i+2); $j >= 0 && $k <= $#$p; $j--, $k++) {
        return 0 unless $p->[$j] == $p->[$k];
    }

    return 1;
}
