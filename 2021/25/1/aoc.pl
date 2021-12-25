#!/usr/bin/env perl

use strict;
use warnings;

my @map = map { chomp; [ split // ] } <>;

my $i = 1;
while (1) {
    @map = step([@map]);
    last unless @map;
    $i++;
}

print $i . "\n";

sub step {
    my $m = shift;

    my $max_y = $#{$m};
    my $max_x = $#{$m->[0]};

    my @res;
    for my $y (0..$max_y) {
        my @row;
        for my $x (0..$max_x) {
            if ($m->[$y][$x] eq '>') {
                my $next_x = ($x < $max_x) ? $x + 1 : 0;
                if ($m->[$y][$next_x] eq '.') {
                    $row[$next_x] = '>';
                }
                else {
                    $row[$x] = '>';
                }
            }
            elsif ($m->[$y][$x] eq 'v') {
                $row[$x] = 'v';
            }
        }
        push @res, [ map { $row[$_] // '.' } (0..$max_x) ];
    }

    @res = map { my $y = $_; [ map { $res[$y][$_] // '.' } (0..$max_x) ] } (0..$max_y);

    my @res2;
    for my $y (0..$max_y) {
        push @res2, [];
        for my $x (0..$max_x) {
            if ($res[$y][$x] eq 'v') {
                my $next_y = ($y < $max_y) ? $y + 1 : 0;
                if ($res[$next_y][$x] eq '.') {
                    $res2[$next_y] //= [];
                    $res2[$next_y][$x] = 'v';
                }
                else {
                    $res2[$y] //= [];
                    $res2[$y][$x] = 'v';
                }
            }
            elsif ($res[$y][$x] eq '>') {
                $res2[$y][$x] = '>';
            }
        }
    }

    @res2 = map { my $y = $_; [ map { $res2[$y][$_] // '.' } (0..$max_x) ] } (0..$max_y);

    my $o = join("\n", map { my $y = $_; join('', map { $m->[$y][$_] } (0..$max_x)) } (0..$max_y));
    my $n = join("\n", map { my $y = $_; join('', map { $res2[$y][$_] } (0..$max_x)) } (0..$max_y));

    return if $o eq $n;

    return @res2;
}
