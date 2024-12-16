#!/usr/bin/env perl

use strict;
use warnings;

my $cols = $ENV{COLUMNS} // 101;
my $rows = $ENV{ROWS} // 103;
my $steps = 100;

my @robots = map { { x => $_->[0], y => $_->[1], dx => $_->[2], dy => $_->[3] } }  map { chomp; [ m/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/ ] } <>;

while ($steps--) {
    @robots = map { my %r = %$_; $r{x} += $r{dx}; $r{y} += $r{dy}; $r{x} %= $cols; $r{y} %= $rows; \%r } @robots;
    #    warn join("\n", map { my $y=$_; join('', map { my $x=$_; my $n=scalar(grep { $y == $_->{y} && $x == $_->{x} } @robots); $n ? $n : '.' } (0..$cols-1))} (0..$rows-1) );
    #    warn "\n";
}

my $res = 1;
$res *= scalar(grep { $_->{x} < ($cols-1)/2 && $_->{y} < ($rows-1)/2 } @robots);
$res *= scalar(grep { $_->{x} > ($cols-1)/2 && $_->{y} < ($rows-1)/2 } @robots);
$res *= scalar(grep { $_->{x} > ($cols-1)/2 && $_->{y} > ($rows-1)/2 } @robots);
$res *= scalar(grep { $_->{x} < ($cols-1)/2 && $_->{y} > ($rows-1)/2 } @robots);

print $res . "\n";
