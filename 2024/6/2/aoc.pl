#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;

my @map = map { chomp; [ map { $_ eq '.' ? 0 : $_ } split //, $_ ] } <>;

my $max_y = $#map;
my $max_x = $#{$map[0]};

my @dirs = (
    [ 0, -1 ],
    [ 1, 0 ],
    [ 0, 1 ],
    [ -1, 0 ],
);
my ($pt) = grep { $map[$_->[1]][$_->[0]] eq '^' } map { my $y = $_; map { [$_,$y] } (0..$max_x) } (0..$max_y);
$map[$pt->[1]][$pt->[0]] = 1;

print scalar(grep { is_loop(dclone(\@map), @$pt, @$_, 0) } map { my $y = $_; map { [$_,$y] } (0..$max_x) } (0..$max_y)) . "\n";
sub is_loop {
    my ($map, $x, $y, $ox, $oy, $d) = @_;

    return 0 if $x == $ox and $y == $oy;
    $map->[$oy][$ox] = '#';

    my $pt = [$x,$y];
    while (1) {
        my ($nx, $ny) = map { $pt->[$_] + $dirs[$d][$_] } (0..1);
        return 0 if $nx < 0 or $nx > $max_x or $ny < 0 or $ny > $max_y;

        if ($map->[$ny][$nx] eq '#') {
            $d++;
            $d %= 4;
            next;
        }

        return 1 if $map->[$ny][$nx] & (1 << $d);

        $map->[$ny][$nx] ^= (1 << $d);
        $pt = [$nx,$ny];
    } 
}
