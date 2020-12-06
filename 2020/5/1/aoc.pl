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

    my $min = 0;
    my $max = 127;

    my @c = split //, $pass;
    for my $c (@c[0..6]) {
        if ($c eq 'F') {
            $max = $max - ($max - $min + 1) / 2;
        }
        elsif ($c eq 'B') {
            $min = $min + ($max - $min + 1 ) / 2;
        }
        else {
            die "Unexpected char: $c";
        }
    }
    die if $min != $max;

    my $row = $min;

    $min = 0;
    $max = 7;
    for my $c (@c[7..9]) {
        if ($c eq 'L') {
            $max = $max - ($max - $min + 1) / 2;
        }
        elsif ($c eq 'R') {
            $min = $min + ($max - $min + 1) / 2;
        }
        else {
            die "Unexpected char: $c";
        }
    }
    die if $min != $max;

    my $column = $min;

    return $row * 8 + $column;
}
