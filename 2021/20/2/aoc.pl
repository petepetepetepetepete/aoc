#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;

my $inf = '.';
my $padding = 2;
my @lines = map { chomp; $_ } <>;
my $iea = [ split //, $lines[0] ];
my $image = [ map { [ split //, $lines[$_] ] } (2..$#lines) ];

for my $i (1..50) {
    $image = enhance($image, $iea);
}

print scalar(grep { $_ } map { my $y = $_; map { int($image->[$y][$_] eq '#') } (0..$#{$image->[0]}) } (0..$#{$image})) . "\n";

sub expand_image{
    my $img = shift;

    for my $line (@$img) {
        unshift @$line, ($inf) x $padding;
        push @$line, ($inf) x $padding;
    }
    my $max_x = $#{$img->[0]};
    unshift @$img, [($inf) x ($max_x+1)] foreach (1..$padding);
    push @$img, [($inf) x ($max_x+1)] foreach (1..$padding);
}

sub enhance {
    my ($img, $algo) = @_;
    expand_image($img);
    my $out = dclone($img);
    my $max_y = $#{$img};
    my $max_x = $#{$img->[0]};
    for my $j (0..$max_y) {
        for my $i (0..$max_x) {
            my $n = oct('0b' . join('', map { my $y = $_; map { my $c = ($_ >= 0 && $_ <= $max_x && $y >= 0 && $y <= $max_y) ? $img->[$y][$_] : $inf; int($c eq '#') } ($i-1..$i+1) } ($j-1..$j+1)));
            $out->[$j][$i] = $algo->[$n];
        }
    }

    $inf = ($inf eq '.') ? $algo->[0] : $algo->[511];

    return $out;
}

