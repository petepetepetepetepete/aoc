#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max/;

my @passes;
while (my $line = <>) {
    chomp $line;
    push @passes, seat_id($line);
}

print max(@passes) . "\n";

sub seat_id {
    my $pass = shift;

    my %map = ('F' => 0, 'B' => 1, 'L' => 0, 'R' => 1);

    my @c = split //, $pass;
    my ($row) = map { oct("0b$_") } join '', map { $map{$_} } @c[0..6];
    my ($col) = map { oct("0b$_") } join '', map { $map{$_} } @c[7..9];

    return $row * 8 + $col;
}
