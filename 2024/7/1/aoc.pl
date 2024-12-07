#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @ops = qw/+ */;

print sum(map { valid($_->[0], @{$_->[1]}) } map { chomp; my @a = split /: /; [ $a[0], [ split / /, $a[1] ] ] } <>) . "\n";

sub valid {
    my ($ans, @nums) = @_;
    return $ans if grep { valid2($ans, $_, @nums) } @ops;
}

sub valid2 {
    my ($ans, $op, $n, @nums) = @_;

    my $m = shift @nums;
    if ($op eq '+') {
        $n += $m;
    }
    elsif ($op eq '*') {
        $n *= $m;
    }

    return 0 if $n > $ans;
    return $n == $ans if !@nums;
    return 1 if grep { valid2($ans, $_, $n, @nums) } @ops;
    return 0;
}
