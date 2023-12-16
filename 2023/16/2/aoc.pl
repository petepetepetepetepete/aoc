#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max/;

my @m = map { chomp; [ split //, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};
my @res;

my %next = (
    '>' => {
        '.' => [ qw/>/ ],
        '/' => [ qw/^/ ],
        '\\' => [ qw/v/ ],
        '-' => [ qw/>/ ],
        '|' => [ qw/^ v/ ],
    },
    '<' => {
        '.' => [ qw/</ ],
        '/' => [ qw/v/ ],
        '\\' => [ qw/^/ ],
        '-' => [ qw/</ ],
        '|' => [ qw/^ v/ ],
    },
    'v' => {
        '.' => [ qw/v/ ],
        '/' => [ qw/</ ],
        '\\' => [ qw/>/ ],
        '-' => [ qw/< >/ ],
        '|' => [ qw/v/ ],
    },
    '^' => {
        '.' => [ qw/^/ ],
        '/' => [ qw/>/ ],
        '\\' => [ qw/</ ],
        '-' => [ qw/< >/ ],
        '|' => [ qw/^/ ],
    }
);

for my $x (0..$max_x) {
    push @res, solve(map { [ $_, $x, 0 ] } @{$next{'v'}{$m[0][$x]}});
    push @res, solve(map { [ $_, $x, $max_y ] } @{$next{'^'}{$m[$max_y][$x]}});
}

for my $y (0..$max_y) {
    push @res, solve(map { [ $_, 0, $y ] } @{$next{'>'}{$m[$y][0]}});
    push @res, solve(map { [ $_, $max_x, $y ] } @{$next{'<'}{$m[$y][$max_x]}});
}

print max(@res) . "\n";

sub solve {
    my @steps = @_;
    my %cache;
    my @m2 = map { [ map { '.' } (0..$max_x) ] } (0..$max_y);

    while (my $step = shift @steps) {
        my ($dir, $x, $y) = @$step;
        my $k = join(',', @$step);
        $cache{$k}++;
        $m2[$y][$x] = '#';

        if ($dir eq '>') {
            next if ++$x > $max_x;
        }
        elsif ($dir eq '<') {
            next if --$x < 0;
        }
        elsif ($dir eq 'v') {
            next if ++$y > $max_y;
        }
        elsif ($dir eq '^') {
            next if --$y < 0;
        }
        else {
            die "Unexpected dir: $dir";
        }

        for my $d (@{$next{$dir}{$m[$y][$x]}}) {
            my $k = "$d,$x,$y";
            push @steps, [ $d, $x, $y ] unless $cache{$k};
        }
    }

    return scalar(grep { $_ eq '#' } map { @$_ } @m2);
}

