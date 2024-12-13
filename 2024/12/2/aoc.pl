#!/usr/bin/env perl

use strict;
use warnings;

my @plot =  map { chomp; [ split // ] } <>;
my $max_y = $#plot;
my $max_x = $#{$plot[0]};

my @dirs = (
    [ -1, 0 ],
    [ 0, -1 ],
    [ 1, 0 ],
    [ 0, 1 ]
);

my %visited;
my $res = 0;
for my $pt (map { my $y=$_; map { [$_,$y] } (0..$max_x) } (0..$max_y)) {
    my $k = join ',', @$pt;
    next if defined $visited{$k};

    my $region = {};
    my ($area, $corners) = find_region(@$pt, $region);
    my ($x, $y) = @$pt;
    $res += $area * $corners;
}

print $res . "\n";

sub find_region {
    my ($x, $y, $region) = @_;
    my $c = $plot[$y][$x];
    my $k = "$x,$y";

    $region->{$k}++;
    $visited{$k}++;

    my $area = 1;
    my $corners = count_corners($x, $y);

    my @next = grep {
        my ($nx,$ny) = @$_;
        my $nk = "$nx,$ny";
        $nx >= 0 && $nx <= $max_x &&
        $ny >= 0 && $ny <= $max_y &&
        $plot[$ny][$nx] eq $c
    } map { [ $x + $_->[0], $y + $_->[1] ] } @dirs;

    for my $pt (@next) {
        my $nk = join ',', @$pt;
        next if defined $region->{$nk};
        my ($a, $c) = find_region(@$pt, $region);
        $area += $a;
        $corners += $c;
    }

    return ($area, $corners);
}

sub count_corners {
    my ($x, $y) = @_;
    my $c = $plot[$y][$x];

    my @all_dirs = (
        [ 0, -1], # up
        [ 1, -1 ], # up/right
        [ 1, 0 ], # right
        [ 1, 1 ], # down/right
        [ 0, 1 ], # down
        [ -1, 1 ], # down/left
        [ -1, 0 ], # left
        [ -1, -1 ], # up/left
    );

    my @surrounding = map {
        my ($nx,$ny) = @$_;
        ($nx >= 0 && $nx <= $max_x && $ny >= 0 && $ny <= $max_y) ? $plot[$ny][$nx] : '?'
    } map { [ $x + $_->[0], $y + $_->[1] ] } @all_dirs;

    my $corners = 0;

    # outer corners
    for (my $i = 0; $i <= $#surrounding; $i += 2) {
        my $j = ($i + 2) % scalar(@surrounding);
        $corners++ if $surrounding[$i] ne $c && $surrounding[$j] ne $c;

    }

    # inner corners
    for (my $i = 0; $i <= $#surrounding; $i += 2) {
        my $j = $i + 1;
        my $k = ($i + 2) % scalar(@surrounding);

        $corners++ if $surrounding[$i] eq $c && $surrounding[$k] eq $c && $surrounding[$j] ne $c;
    }

    return $corners;
}

