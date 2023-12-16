#!/usr/bin/env perl

use strict;
use warnings;

my @m = map { chomp; [ split //, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};
my @m2 = map { [ map { '.' } (0..$max_x) ] } (0..$max_y);

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

my %cache;
my @steps = map { [ $_, 0, 0 ] } @{$next{'>'}{$m[0][0]}};
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

print scalar(grep { $_ eq '#' } map { @$_ } @m2) . "\n";

