#!/usr/bin/env perl

use strict;
use warnings;

use constant MIN_X => 0;
use constant MAX_X => 1;
use constant MIN_Y => 2;
use constant MAX_Y => 3;
use constant MIN_Z => 4;
use constant MAX_Z => 5;

use List::Util qw/any min max sum/;

my @cubes;
while (my $line = <>) {
    chomp $line;
    my ($power, @pts) = $line =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/;
    next if any { $_ < -50 || $_ > 50 } @pts;
    my @tmp;
    for my $c (@cubes) {
        my @c = add_cube($c, [@pts]);
        push @tmp, @c;
    }
    push @tmp, [@pts] if $power eq 'on';
    @cubes = @tmp;
}
print sum(map { ($_->[MAX_X]-$_->[MIN_X]+1)*($_->[MAX_Y]-$_->[MIN_Y]+1)*($_->[MAX_Z]-$_->[MIN_Z]+1) } @cubes) . "\n";

sub add_cube {
    my ($o, $n) = @_;

    # new cube does not overlap with old cube - return old cube
    if ($n->[MIN_X] > $o->[MAX_X] || $n->[MAX_X] < $o->[MIN_X] ||
        $n->[MIN_Y] > $o->[MAX_Y] || $n->[MAX_Y] < $o->[MIN_Y] ||
        $n->[MIN_Z] > $o->[MAX_Z] || $n->[MAX_Z] < $o->[MIN_Z])
    {
        return $o;
    }

    # old rect fits entirely in new rect
    if ($o->[MIN_X] >= $n->[MIN_X] && $o->[MAX_X] <= $n->[MAX_X] &&
        $o->[MIN_Y] >= $n->[MIN_Y] && $o->[MAX_Y] <= $n->[MAX_Y] &&
        $o->[MIN_Z] >= $n->[MIN_Z] && $o->[MAX_Z] <= $n->[MAX_Z])
    {
        return;
    }

    my @skip;

    my @x;
    push @x, [$o->[MIN_X],$n->[MIN_X]-1] if $o->[MIN_X] < $n->[MIN_X];
    push @x, [max($o->[MIN_X],$n->[MIN_X]), min($o->[MAX_X],$n->[MAX_X])];
    push @skip, @{$x[-1]};
    push @x, [$n->[MAX_X]+1,$o->[MAX_X]] if $o->[MAX_X] > $n->[MAX_X];

    my @y;
    push @y, [$o->[MIN_Y],$n->[MIN_Y]-1] if $o->[MIN_Y] < $n->[MIN_Y];
    push @y, [max($o->[MIN_Y],$n->[MIN_Y]), min($o->[MAX_Y],$n->[MAX_Y])];
    push @skip, @{$y[-1]};
    push @y, [$n->[MAX_Y]+1,$o->[MAX_Y]] if $o->[MAX_Y] > $n->[MAX_Y];

    my @z;
    push @z, [$o->[MIN_Z],$n->[MIN_Z]-1] if $o->[MIN_Z] < $n->[MIN_Z];
    push @z, [max($o->[MIN_Z],$n->[MIN_Z]), min($o->[MAX_Z],$n->[MAX_Z])];
    push @skip, @{$z[-1]};
    push @z, [$n->[MAX_Z]+1,$o->[MAX_Z]] if $o->[MAX_Z] > $n->[MAX_Z];

    my @res;
    for my $x (@x) {
        for my $y (@y) {
            for my $z (@z) {
                # Skip the cube that matches n
                next if $x->[0] == $skip[0] && $x->[1] == $skip[1] &&
                        $y->[0] == $skip[2] && $y->[1] == $skip[3] &&
                        $z->[0] == $skip[4] && $z->[1] == $skip[5];

                push @res, [@$x,@$y,@$z];
            }
        }
    }

    return @res;
}
