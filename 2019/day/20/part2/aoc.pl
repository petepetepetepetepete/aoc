#!/usr/bin/env perl

use strict;
use warnings;

use Graph;

my $g = Graph->new(directed => 0);

my @map;
while (my $line = <STDIN>) {
    chomp $line;
    push @map, [ split //, $line ];
}

my $max_z = 30;
my $max_y = $#map;
my $max_x = $#{$map[0]};

my %portals;
my $start;
my $end;

for my $y (0..$max_y) {
    for my $x (0..$max_x) {
        my $c = $map[$y][$x];
        if ($c eq '.') {
            for my $pt ([$x-1,$y],[$x,$y-1],[$x+1,$y],[$x,$y+1]) {
                next if $pt->[0] < 0 || $pt->[1] < 0;
                next if $pt->[0] > $max_x || $pt->[1] > $max_y;
                next unless $map[$pt->[1]][$pt->[0]] eq '.';

                $g->add_edge("$x,$y,$_", "$pt->[0],$pt->[1],$_") for (0..$max_z);
            }
        }

        my $s = join('', $map[$y][$x], ($map[$y][$x+1] // ''), ($map[$y][$x+2] // ''));
        my $p = '';
        my ($i,$j);
        if ($s =~ m/([A-Z]{2})\./) {
            $p = $1;
            $i = $x+2;
            $j = $y;
        }
        elsif ($s =~ m/\.([A-Z]{2})/) {
            $p = $1;
            $i = $x;
            $j = $y;
        }

        if ($p eq 'AA') {
            $start = [$i,$j,0];
        }
        elsif ($p eq 'ZZ') {
            $end = [$i,$j,0];
        }
        elsif ($p) {
            push @{$portals{$p}}, [$i,$j];
        }
    }
}

for my $x (0..$max_x) {
    for my $y (0..$max_y) {
        my $s = join('', $map[$y][$x], ($map[$y+1][$x] // ''), ($map[$y+2][$x] // ''));
        my $p = '';
        my ($i,$j);
        if ($s =~ m/([A-Z]{2})\./) {
            $p = $1;
            $i = $x;
            $j = $y+2;
        }
        elsif ($s =~ m/\.([A-Z]{2})/) {
            $p = $1;
            $i = $x;
            $j = $y;
        }

        if ($p eq 'AA') {
            $start = [$i,$j,0];
        }
        elsif ($p eq 'ZZ') {
            $end = [$i,$j,0];
        }
        elsif ($p) {
            push @{$portals{$p}}, [$i,$j];
        }
    }
}

for my $p (grep { $_ ne 'AA' && $_ ne 'ZZ' } keys %portals) {
    my $p1 = $portals{$p}[0];
    my $p2 = $portals{$p}[1];

    my @path = ($p1,$p2);
    if ($p1->[0] == 2 || $p1->[0] == $max_x-2 || $p1->[1] == 2 || $p1->[1] == $max_y-2) {
        @path = ($p2,$p1);
    }

    for my $z (0..$max_z-1) {
        my $pp1 = join(',', @{$path[0]}, $z);
        my $pp2 = join(',', @{$path[1]}, $z+1);
        $g->add_edge($pp1, $pp2);
    }

}

my @path = $g->SP_Dijkstra(join(',', @$start), join(',', @$end));
print "$#path\n";

