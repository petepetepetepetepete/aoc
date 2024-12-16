#!/usr/bin/env perl

use strict;
use warnings;

my $cols = $ENV{COLUMNS} // 101;
my $rows = $ENV{ROWS} // 103;
my $steps = $rows*$cols;
my $min;

my %x;
my @robots = map { { x => $_->[0], y => $_->[1], dx => $_->[2], dy => $_->[3] } }  map { chomp; [ m/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/ ] } <>;

for my $i (1..$steps) {
    @robots = map { my %r = %$_; $r{x} += $r{dx}; $r{y} += $r{dy}; $r{x} %= $cols; $r{y} %= $rows; \%r } @robots;
    my $sf = safety_factor();
    $min //= $sf;

    my $picture = '';
    if ($sf < $min) {
        $picture = join("\n", map { my $y=$_; join('', map { my $x=$_; my $n=scalar(grep { $y == $_->{y} && $x == $_->{x} } @robots); $n ? $n : '.' } (0..$cols-1))} (0..$rows-1) );
        $min = $sf;
    }

    $x{$i} = {
        safety_factor => $sf,
        picture => $picture,
    };
}

my @s = sort { $x{$a}{safety_factor} <=> $x{$b}{safety_factor} } keys %x;
#for my $i (@s) {
#    warn $i;
#    warn $x{$i}{picture};
#    sleep 1;
#}
print $s[0] . "\n";

sub safety_factor {
    my $res = 1;
    $res *= scalar(grep { $_->{x} < ($cols-1)/2 && $_->{y} < ($rows-1)/2 } @robots);
    $res *= scalar(grep { $_->{x} > ($cols-1)/2 && $_->{y} < ($rows-1)/2 } @robots);
    $res *= scalar(grep { $_->{x} > ($cols-1)/2 && $_->{y} > ($rows-1)/2 } @robots);
    $res *= scalar(grep { $_->{x} < ($cols-1)/2 && $_->{y} > ($rows-1)/2 } @robots);
    return $res;
}

