#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max/;

my %x = (3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1);

my @board = (10, 1..9);
my @players = map { chomp; (split /: /)[-1] } <>;
my @scores = (0) x 2;

my @res = game([@players], 0, [@scores]);
print max(@res) . "\n";

sub game {
    my ($p, $cur, $s, $n) = @_;

    my @res = (0) x 2;

    if (!defined $n) {
        for my $k (sort keys %x) {
            warn "$k";
            my @a = game([@$p], $cur, [@$s], $k);
            $res[$_] += ($x{$k} * $a[$_]) foreach (0..$#a);
        }
        return @res;
    }

    $p->[$cur % 2] += $n;
    $p->[$cur % 2] %= 10;
    $s->[$cur % 2] += $board[$p->[$cur % 2]];

    if ($s->[$cur % 2] >= 21) {
        $res[$cur % 2]++;
        return @res;
    }

    for my $k (sort keys %x) {
        my @a = game([@$p], $cur + 1, [@$s], $k, $x{$k});
        $res[$_] += ($x{$k} * $a[$_]) foreach (0..$#a);
    }

    return @res;
}

