#!/usr/bin/env perl

use strict;
use warnings;

my $max = -1;
while (my $line = <>) {
    chomp $line;
    my $sid = seat_id($line);
    $max = $sid if $sid > $max;
}

print $max . "\n";

sub seat_id {
    my $pass = shift;

    my %map = ('F' => 0, 'B' => 1, 'L' => 0, 'R' => 1);

    my @c = split //, $pass;
    my ($row) = map { oct("0b$_") } join '', map { $map{$_} } @c[0..6];
    my ($col) = map { oct("0b$_") } join '', map { $map{$_} } @c[7..9];

    return $row * 8 + $col;
}
