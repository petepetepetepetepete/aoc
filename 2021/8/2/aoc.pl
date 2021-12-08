#!/usr/bin/env perl

use strict;
use warnings;

my $res = 0;
while (my $line = <>) {
    chomp $line;
    $res += output_value($line);
}

print $res . "\n";

sub output_value {
    my $line = shift;

    my $res = '';

    my @a = split / \| /, $line;
    my @signal = split / /, $a[0];
    my @out = split / /, $a[1];
    my @digits = (@signal, @out);

    my @segments = ('abcdefg') x 7;

    my $one = (grep { length($_) == 2 } @digits)[0];
    $segments[2] = $segments[5] = $one;

    my $seven = (grep { length($_) == 3 } @digits)[0];
    $seven =~ s/$_// foreach split //, $one;
    $segments[0] = $seven;

    my $four = (grep { length($_) == 4 } @digits)[0];
    $four =~ s/$_// foreach split //, $one;
    $segments[1] = $segments[3] = $four;

    my $eight = (grep { length($_) == 7 } @digits)[0];
    $eight =~ s/$_// foreach split //, $one;
    $eight =~ s/$_// foreach split //, $seven;
    $eight =~ s/$_// foreach split //, $four;
    $segments[4] = $segments[6] = $eight;

    for my $digit (@digits) {
        my @x = split //, $segments[0] . $segments[2] . $segments[1];
        if (length($digit) == 6) {
            my $digit2 = $digit;
            $digit2 =~ s/$_// foreach @x;
            if (length($digit2) == 1) {
                $segments[6] = $digit2;
                $segments[4] =~ s/$digit2//;
                last;
            }
        }
    }

    for my $digit (@digits) {
        my @x = split //, $segments[0] . $segments[2] . $segments[4] . $segments[6];
        if (length($digit) == 6) {
            my $digit2 = $digit;
            $digit2 =~ s/$_// foreach @x;
            if (length($digit2) == 1) {
                $segments[1] = $digit2;
                $segments[3] =~ s/$digit2//;
                last;
            }
        }
    }

    for my $digit (@digits) {
        my @x = split //, $segments[0] . $segments[3] . $segments[4] . $segments[6];
        if (length($digit) == 5) {
            my $digit2 = $digit;
            $digit2 =~ s/$_// foreach @x;
            if (length($digit2) == 1) {
                $segments[2] = $digit2;
                $segments[5] =~ s/$digit2//;
                last;
            }
        }
    }

    my %map = (
        join('', sort(map { $segments[$_] } (0, 1, 2, 4, 5, 6))) => 0,
        join('', sort(map { $segments[$_] } (2, 5))) => 1,
        join('', sort(map { $segments[$_] } (0, 2, 3, 4, 6))) => 2,
        join('', sort(map { $segments[$_] } (0, 2, 3, 5, 6))) => 3,
        join('', sort(map { $segments[$_] } (1, 2, 3, 5))) => 4,
        join('', sort(map { $segments[$_] } (0, 1, 3, 5, 6))) => 5,
        join('', sort(map { $segments[$_] } (0, 1, 3, 4, 5, 6))) => 6,
        join('', sort(map { $segments[$_] } (0, 2, 5))) => 7,
        join('', sort(map { $segments[$_] } (0..6))) => 8,
        join('', sort(map { $segments[$_] } (0, 1, 2, 3, 5, 6))) => 9,
    );

    for my $out (@out) {
        my $s = join('', sort(split //, $out));
        $res .= $map{$s};
    }

    return int($res);
}
