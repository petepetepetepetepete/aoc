#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;
use Memoize;

memoize('xxx');
memoize('yyy');

my @stones = map { chomp; split / / } <>;

my $count = 25;

print sum(map { xxx($_, $count) } @stones) . "\n";

sub xxx {
    my ($num, $depth) = @_;

    my @a = yyy($num);
    return scalar(@a) if $depth == 1;
    return sum(map { xxx($_, $depth-1) } @a);

}

sub yyy {
    my ($num) = @_;

    if ($num == 0) {
        return 1;
    }
    elsif (length($num) % 2 == 0) {
        my $mid = length($num) / 2;
        return (int(substr($num, 0, $mid)), int(substr($num, $mid)));
    }

    return 2024 * $num;
}
