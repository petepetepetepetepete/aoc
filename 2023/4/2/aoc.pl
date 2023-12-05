#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @cards = map { chomp; $_ } <>;
my @multipliers = map { 1 } (@cards);

for my $i (0..$#cards) {
    my ($a, $b) = split /: /, $cards[$i];
    my ($id) = $a =~ m/^Card +(\d+)/;
    my ($winning_numbers, $my_numbers) = split / \| /, $b;

    my %w = map { $_ => 1 } grep { $_ ne '' } split / +/, $winning_numbers;
    my @m = grep { $_ ne '' and exists $w{$_} } split / +/, $my_numbers;

    next unless @m;

    for my $j (0..$#m) {
        $multipliers[$i+$j+1] += $multipliers[$i];
    }
}

print sum(@multipliers) . "\n";

