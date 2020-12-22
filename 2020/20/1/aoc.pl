#!/usr/bin/env perl

use strict;
use warnings;

my $id;
my @map;
my %tiles;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^Tile (\d+):$/) {
        $id = $1;
    }
    elsif ($line eq '') {
        $tiles{$id}{map} = [ @map ];
        @map = ();
    }
    elsif ($line =~ m/^[.#]{10}$/) {
        push @map, [ split //, $line ];
    }
    else {
        die "Unexpected line: $line";
    }
}
$tiles{$id}{map} = [ @map ];

my @orientations = (
    [ 1, 1, 0, 0 ],
    [ 1, 0, 0, 1 ],
    [ 0, 0, 1, 1 ],
    [ 0, 1, 1, 0 ],
);

my %h;
for my $id (keys %tiles) {
    my $map = $tiles{$id}{map};
    $tiles{$id}{orientations} ||= [];
    $tiles{$id}{reverse_orientations} ||= [];

    my @edges = (
        [ map { $map->[0][$_] } (0..9) ],
        [ map { $map->[$_][9] } (0..9) ],
        [ map { $map->[9][$_] } (0..9) ],
        [ map { $map->[$_][0] } (0..9) ],
    );

    for my $e (@edges) {
        push @{$tiles{$id}{edges}}, oct('0b' . join('', map { $_ eq '#' ? 1 : 0 } @$e));
        $h{$tiles{$id}{edges}->[-1]}++;
        push @{$tiles{$id}{reverse_edges}}, oct('0b' . join('', map { $_ eq '#' ? 1 : 0 } reverse @$e));
        $h{$tiles{$id}{reverse_edges}->[-1]}++;
    }
}

my $res = 1;
for my $id (keys %tiles) {
    my $matches = 0;
    for my $e (@{$tiles{$id}{edges}}, @{$tiles{$id}{reverse_edges}}) {
        $matches++ if grep { $_ == $e } map { @{$tiles{$_}{edges}} } grep { $_ ne $id  } keys %tiles; 
    }

    $res *= $id if $matches == 2;
}

print $res . "\n";
