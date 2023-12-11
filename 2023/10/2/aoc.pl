#!/usr/bin/env perl

use strict;
use warnings;

my @dir = (
    # dx, dy, re next, re current
    [ -1, 0, '^[SLF-]$', '^[SJ7-]$' ],
    [ 1, 0,  '^[SJ7-]$', '^[SLF-]$' ],
    [ 0, -1, '^[SF7|]$', '^[SLJ|]$' ],
    [ 0, 1,  '^[SLJ|]$', '^[SF7|]$' ]
);

my %start_map = (
    '-1,0' => {
        '1,0' => '-',
        '0,-1' => 'J',
        '0,1' => '7',
    },
    '1,0' => {
        '-1,0' => '-',
        '0,-1' => 'L',
        '0,1' => 'F',
    },
    '0,-1' => {
        '-1,0' => 'J',
        '1,0' => 'L',
        '0,1' => '|',
    },
    '0,1' => {
        '-1,0' => '7',
        '1,0' => 'F',
        '0,-1' => '|',
    }
);

my @map = map { chomp; [ split(//, $_) ] } <>;
my $max_x = $#{$map[0]};
my $max_y = $#map;

my @v = map { [ map { '.' } (0..$max_x) ] } (0..$max_y);

# find position of start point
my ($sx, $sy) = map { ($_->[1], $_->[0]) } grep { $map[$_->[0]][$_->[1]] eq 'S' } map { my $y = $_; map { [ $y, $_ ] } (0..$max_x) } (0..$max_y);

my @n = grep {
    $_->[0] >= 0 && $_->[0] <= $max_x &&
    $_->[1] >= 0 && $_->[1] <= $max_y &&
    $map[$_->[1]][$_->[0]] =~ qr/$_->[2]/
} map { [ $sx+$_->[0], $sy+$_->[1], $_->[2] ] } @dir;
$v[$sy][$sx] = $map[$sy][$sx];

die unless @n == 2;

my @d = map { [ $_->[0] - $sx, $_->[1] - $sy ] } @n;
$v[$sy][$sx] = $start_map{"$d[0]->[0],$d[0]->[1]"}{"$d[1]->[0],$d[1]->[1]"} // die;

my ($x, $y) = @{$n[0]};

my ($px, $py) = ($sx, $sy);

while ($x != $sx || $y != $sy) {
    $v[$y][$x] = $map[$y][$x];
    my @n = grep {
        !($_->[0] == $px && $_->[1] == $py) && # don't backtrack
        $_->[0] >= 0 && $_->[0] <= $max_x && $_->[1] >= 0 && $_->[1] <= $max_y && # out of bounds
        $map[$_->[1]][$_->[0]] =~ qr/$_->[2]/ && # next connects to current
        $map[$y][$x] =~ qr/$_->[3]/ # current connects to next
    } map { [ $x+$_->[0], $y+$_->[1], $_->[2], $_->[3] ] } @dir;

    die "$px,$py,$map[$py][$px] -> $x,$y,$map[$y][$x]" unless @n == 1;

    ($px, $py) = ($x, $y);
    ($x, $y) = @{$n[0]};
}

my @pts = grep { $v[$_->[1]][$_->[0]] eq '.' } map { my $y=$_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);
my $result = 0;

for my $pt (@pts) {
    my ($x, $y) = @$pt;

    my $pc;
    my $inside = 0;
    for my $i (0..$x-1) {
        my $c = $v[$y][$i];

        if ($c eq '|') {
            $inside ^= 1;
        }
        elsif ($c =~ m/^[LF]$/) {
            $pc = $c;
            $inside ^= 1;
        }
        elsif ($c eq 'J' && $pc eq 'L') {
            undef $pc;
            $inside ^= 1;
        }
        elsif ($c eq '7' && $pc eq 'F') {
            undef $pc;
            $inside ^= 1;
        }
    }

    $result++ if $inside;
}

print $result . "\n";
