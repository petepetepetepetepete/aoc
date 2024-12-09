#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $in = do { local $/; <> };
chomp $in;

my $id = 0;
my @x = map {
    my ($a,$b) = split //;
    $b ||= 0;
    $id++;
    ((map { $id-1 } (1..$a)), (map { '.' } (1..$b)))
} $in =~ m/(\d{1,2})/g;

my @a;
while (@x) {
    my $x = shift @x;
    if ($x ne '.') {
        push @a, $x;
    }
    else {
        do {
            $x = pop @x;
        } while (defined $x && $x eq '.');

        push @a, $x if defined $x;
    }
}

print sum(map { ($a[$_] eq '.' ? 0 : $a[$_]) * $_ } (0..$#a)) . "\n";
