#!/usr/bin/env perl

use strict;
use warnings;

my $steps = shift;
my @m = map { chomp; [ split//, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};

my @pts = grep { $m[$_->[1]][$_->[0]] eq 'S' } map { my $y=$_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);

for my $step (1..$steps) {
    my @newpts = ();
    #warn join("\n", map { my $y=$_; join('', map { my $x=$_; (grep { $_->[0] == $x && $_->[1] == $y } @pts) ? 'O' : $m[$y][$x] } (0..$max_x)) } (0..$max_y));
    for my $pt (@pts) {
        for my $off ([-1,0],[1,0],[0,-1],[0,1]) {
            my $newpt = [ map { $pt->[$_] + $off->[$_]  } (0..1) ];
            next if $newpt->[0] < 0 or $newpt->[0] > $max_x or $newpt->[1] < 0 or $newpt->[1] > $max_y;
            next if grep { $_->[0] == $newpt->[0] && $_->[1] == $newpt->[1] } @newpts;

            my $c = $m[$newpt->[1]][$newpt->[0]];
            push @newpts, $newpt if $c =~ m/^[S.]$/;
        }
    }
    @pts = @newpts;
}

print scalar(@pts) . "\n";
