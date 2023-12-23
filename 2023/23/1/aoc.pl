#!/usr/bin/env perl

use strict;
use warnings;

use Graph;
use List::Util qw/max/;
use Storable qw/dclone/;

my @m = map { chomp; [ split //, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};

my ($start) = map { [$_,0] } grep { $m[0][$_] eq '.' } (0..$max_x);
my ($target) = map { [$_,$max_y] } grep { $m[$max_y][$_] eq '.' } (0..$max_x);

my $end = join(',', @$target);

my $g = Graph->new(directed => 1);
for my $y (0..$max_y) {
    for my $x (0..$max_x) {
        next unless $m[$y][$x] =~ m/^[<>^v.]$/;

        my $s = "$x,$y";
        if ($m[$y][$x] =~ m/^([<>^v])$/) {
            my $c = $1;
            my ($nx,$ny)=($x,$y);
            if ($c eq '<') {
                $nx--;
            }
            elsif ($c eq '>') {
                $nx++;
            }
            elsif ($c eq '^') {
                $ny--;
            }
            elsif ($c eq 'v') {
                $ny++;
            }
            $g->add_edge($s, "$nx,$ny");
        }

        for my $pt ([1,0],[-1,0],[0,-1],[0,1]) {
            my $nx = $x + $pt->[0];
            my $ny = $y + $pt->[1];
            next if $nx < 0 or $nx > $max_x or $ny < 0 or $ny > $max_y;
            my $c = $m[$ny][$nx];
            next unless $c =~ m/^[<>^v.]$/;

            # skip if this neighbour is a slope that directs towards us
            if ($c eq '<' && $pt->[0] == 1) {
                next;
            }
            elsif ($c eq '>' && $pt->[0] == -1) {
                next;
            }
            elsif ($c eq '^' && $pt->[1] == 1) {
                next;
            }
            elsif ($c eq 'v' && $pt->[1] == -1) {
                next;
            }

            $g->add_edge($s, "$nx,$ny");
        }
    }
}

my @paths;
my @q = map { [ $_, [], {} ] } $g->successors("$start->[0],$start->[1]");
while (@q) {
    warn scalar(@q) . ' / ' . scalar(@paths) . "\n";
    my $step = shift @q;
    my ($u, $path, $seen) = @$step;

    push @$path, $u;
    $seen->{$u}++;

    if ($u eq $end) {
        push @paths, $path;
        next;
    }

    push @q, map { [ $_, dclone($path), dclone($seen) ] } grep { !exists $seen->{$_} } $g->successors($u);
}

print max(map { scalar(@$_) } @paths) . "\n";

