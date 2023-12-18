#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/all min sum/;

my %opp = (
    '>' => '<',
    '<' => '>',
    '^' => 'v',
    'v' => '^',
);
my %dir = (
    '>' => [1,0],
    '<' => [-1,0],
    '^' => [0,-1],
    'v' => [0,1],
);

my @m = map { chomp; [ split //, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};

my @steps = map { [ [ $_ ], 0 ] } get_next(0, 0);

my @paths;
my @directions;
my @hl;
my %cache;
while (my $step = shift @steps) {
    my ($path, $hl) = @$step;
    my @path = @$path;
    my $prev = $path[-1];

    my ($x, $y, $dir) = @$prev;

    my $hl2 = $hl + $m[$y][$x];
    if ($x == $max_x && $y == $max_y) {
        push @paths, [ $path, $hl2 ];
        next;
    }

    for my $next (get_next($x, $y, $path)) {
        my $k = join(',', @$prev,@$next);
        next if (defined $cache{$k} && $cache{$k} < $hl2);

        $cache{$k} = $hl2;
        push @steps, [
            [ @$path, $next ],
            $hl2
        ];
    }
}

my @spaths = sort { $a->[1] <=> $b->[1] } @paths;
print $spaths[0][1] . "\n";

sub get_next {
    my ($x, $y, $prev) = @_;
    $prev //= [];

    my @next;
    for my $d (qw/> < ^ v/) {
        my $nx = $x + $dir{$d}[0];
        my $ny = $y + $dir{$d}[1];
        next if $nx < 0 or $nx > $max_x or $ny < 0 or $ny > $max_y;

        # no backtracking
        next if scalar(@$prev) >= 2 && $prev->[-2][0] == $nx && $prev->[-2][1] == $ny;

        # can't move in the same direction for more than three blocks
        next if scalar(@$prev) >= 3 && all { $_->[2] eq $d } @{$prev}[-3..-1];

        push @next, [ $nx, $ny, $d ];
    }

    return @next;
}
