#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min max reduce/;
use Math::Prime::Util qw/gcd/;

my ($infile, $idx) = @ARGV;
my @asteroids;
my @map;
my $y = 0;
my $pt;
open my $fh, "<$infile" or die;
while (my $line = <$fh>) {
    chomp($line);
    push @{$map[$y]}, split //, $line;
    push @asteroids, map { { x => $_, y => $y } } grep { defined $_ } map { $map[$y][$_] eq '#' ? $_ : undef } (0..$#{$map[$y]});

    ($pt) = map { { x => $_, y => $y } } grep { defined $_ } map { $map[$y][$_] eq 'X' ? $_ : undef } (0..$#{$map[$y]}) unless $pt;

    $y++;
}
close $fh;

for my $a (@asteroids) {
    my @other_asteroids = grep { $_->{x} != $a->{x} || $_->{y} != $a->{y} } @asteroids;
    for my $o (@other_asteroids) {
        my @points = get_points($a, $o);
        $a->{detected}++ if scalar(grep { $map[$_->{y}][$_->{x}] ne '.'  } @points) == 0;
    }
}

$pt ||= reduce { $a->{detected} > $b->{detected} ? $a : $b } @asteroids;

my @other_asteroids = grep { $_->{x} != $pt->{x} || $_->{y} != $pt->{y} } @asteroids;
for my $a (@other_asteroids) {
    my $rise = $a->{y} - $pt->{y};
    my $run = $a->{x} - $pt->{x};
    $a->{angle} = atan2($run, $rise);

    my $dx = abs($pt->{x} - $a->{x});
    my $dy = abs($pt->{y} - $a->{y});
    $a->{dist} = sqrt($dx*$dx + $dy*$dy);
}

my @zapped;
while (@other_asteroids) {
    my $last_angle = -999;
    my @removed_idxs = ();
    for my $i (sort { $other_asteroids[$b]->{angle} <=> $other_asteroids[$a]->{angle} || $other_asteroids[$a]->{dist} <=> $other_asteroids[$b]->{dist} } (0..$#other_asteroids)) {
        my $o = $other_asteroids[$i];
        next if ($o->{angle} == $last_angle);

        push @removed_idxs, $i;
        push @zapped, $o;

        $last_angle = $o->{angle};
    }

    for my $i (sort { $b <=> $a } @removed_idxs) {
        splice(@other_asteroids, $i, 1);
    }
}

if ($idx) {
    printf "%d\n", 100*$zapped[$idx-1]->{x} + $zapped[$idx-1]->{y};
}
else {
    print for map { sprintf "%d,%d\n", $_->{x}, $_->{y} } @zapped;
}

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
