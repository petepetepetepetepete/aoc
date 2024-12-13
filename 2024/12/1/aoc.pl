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
    my ($area, $perimeter) = find_region(@$pt, $region);
    use Data::Dumper;
    $res += $area * $perimeter;
}

print $res . "\n";

sub find_region {
    my ($x, $y, $region) = @_;
    my $c = $plot[$y][$x];
    my $k = "$x,$y";

    $region->{$k}++;
    $visited{$k}++;

    my @next = grep {
        my ($nx,$ny) = @$_;
        my $nk = "$nx,$ny";
        $nx >= 0 && $nx <= $max_x &&
        $ny >= 0 && $ny <= $max_y &&
        $plot[$ny][$nx] eq $c
    } map { [ $x + $_->[0], $y + $_->[1] ] } @dirs;

    my $area = 1;
    my $perimeter = 4 - scalar(@next);

    for my $pt (@next) {
        my $nk = join ',', @$pt;
        next if defined $region->{$nk};
        my ($a, $p) = find_region(@$pt, $region);
        $area += $a;
        $perimeter += $p;
    }

    return ($area, $perimeter);
}
