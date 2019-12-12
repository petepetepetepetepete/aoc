#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min max/;
use Math::Prime::Util qw/gcd/;

my @asteroids;
my @map;
my $y = 0;
while (my $line = <>) {
    chomp($line);
    push @{$map[$y]}, split //, $line;
    push @asteroids, map { { x => $_, y => $y } } grep { defined $_ } map { $map[$y][$_] eq '#' ? $_ : undef } (0..$#{$map[$y]});
    $y++;
}

for my $a (@asteroids) {
    my @other_asteroids = grep { $_->{x} != $a->{x} || $_->{y} != $a->{y} } @asteroids;
    for my $o (@other_asteroids) {
        my @points = get_points($a, $o);
        $a->{detected}++ if scalar(grep { $map[$_->{y}][$_->{x}] ne '.'  } @points) == 0;
    }
}

my $max = max(map { $_->{detected} // 0 } @asteroids);
print "$max\n";

sub get_points {
    my ($a, $b) = @_;

    my $rise = $b->{y} - $a->{y};
    my $run = $b->{x} - $a->{x};

    my $slope = $run != 0 ? $rise / $run : undef;

    if (!defined $slope) {
        return map { { x => $a->{x}, y => $_ } } (min($a->{y}+1,$b->{y}+1)..max($a->{y}-1,$b->{y}-1));
    }
    elsif ($slope == 0) {
        return map { { x => $_, y => $a->{y} } } (min($a->{x}+1,$b->{x}+1)..max($a->{x}-1,$b->{x}-1));
    }
    else {
        my @points;

        my $gcd = gcd($rise, $run);
        $rise /= $gcd;
        $run /= $gcd;

        my $x1 = $a->{x} + $run;
        my $y1 = $a->{y} + $rise;
        while ($x1 != $b->{x} || $y1 != $b->{y}) {
            push @points, { x => $x1, y => $y1 };
            $x1 += $run;
            $y1 += $rise;
        }

        return @points;
    }
}
