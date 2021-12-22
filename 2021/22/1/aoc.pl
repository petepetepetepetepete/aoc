#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/any/;

my %map;
my $res = 0;
while (my $line = <>) {
    chomp $line;
    my ($power, @pts) = $line =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/;
    next if any { $_ < -50 || $_ > 50 } @pts;
    for my $x ($pts[0]..$pts[1]) {
        for my $y ($pts[2]..$pts[3]) {
            for my $z ($pts[4]..$pts[5]) {
                if ($power eq 'off' && $map{$z}{$y}{$x}) {
                    $res--;
                }
                elsif ($power eq 'on' && !$map{$z}{$y}{$x}) {
                    $res++;
                }
                $map{$z}{$y}{$x} = int($power eq 'on');
            }
        }
    }
}
print $res . "\n";
