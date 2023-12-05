#!/usr/bin/env perl

use strict;
use warnings;

my $result = 0;
while (my $line = <>) {
    chomp $line;
    my ($a, $b) = split /: /, $line;
    my ($id) = $a =~ m/^Card +(\d+)/;
    my ($winning_numbers, $my_numbers) = split / \| /, $b;

    my %w = map { $_ => 1 } grep { $_ ne '' } split / +/, $winning_numbers;
    my @m = grep { $_ ne '' and exists $w{$_} } split / +/, $my_numbers;

    $result += 2**$#m if @m > 0;
}

print $result . "\n";

