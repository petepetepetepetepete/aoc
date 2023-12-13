#!/usr/bin/env perl

use strict;
use warnings;

my $input = join '', <>;

use List::Util qw/sum/;

my @masks = map { 1 << $_ } (0..16);

my @p;
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

my $result = 0;
for my $pp (@p) {
    my ($m, $p) = @$pp;
    for my $i (0..$#$p-1) {
        if (grep { $_->[0] == $_->[1] } map { [ $p->[$i] ^ $_, $p->[$i+1] ], [ $p->[$i], $p->[$i+1] ^ $_ ] } @masks) {
            if (mirror($i, $p, 1)) {
                $result += $m*($i+1);
            }
        }
        elsif ($p->[$i] == $p->[$i+1]) {
            if (mirror($i, $p, 0)) {
                $result += $m*($i+1);
            }
        }
    }
}

print $result . "\n";

sub mirror {
    my ($i, $p, $b) = @_;

    for (my ($j, $k) = ($i-1, $i+2); $j >= 0 && $k <= $#$p; $j--, $k++) {
        if (!$b) {
            if (grep { $_->[0] == $_->[1] } map { [ $p->[$j] ^ $_, $p->[$k] ], [ $p->[$j], $p->[$k] ^ $_ ] } @masks) {
                $b = 1;
                next;
            }
        }

        if ($p->[$j] != $p->[$k]) {
            return 0;
        }
    }

    return $b;
}
