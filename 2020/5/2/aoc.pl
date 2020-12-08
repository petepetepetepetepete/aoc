#!/usr/bin/env perl

use strict;
use warnings;

my $m;
my $n;
my $sum = 0;
while (my $line = <>) {
    chomp $line;
    my $sid = seat_id($line);
    $sum += $sid;
    $m //= $sid;
    $n //= $sid;
    $m = $sid if $sid < $m;
    $n = $sid if $sid > $n;
}

my $seat_id = ($n * $n + $n) / 2 - ($m * $m - $m) / 2 - $sum;
print $seat_id . "\n";

sub seat_id {
    my $pass = shift;

    my %map = ('F' => 0, 'B' => 1, 'L' => 0, 'R' => 1);

    my @c = split //, $pass;
    my ($row) = map { oct("0b$_") } join '', map { $map{$_} } @c[0..6];
    my ($col) = map { oct("0b$_") } join '', map { $map{$_} } @c[7..9];

    return $row * 8 + $col;
}
