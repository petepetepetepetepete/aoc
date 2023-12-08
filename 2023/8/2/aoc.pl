#!/usr/bin/env perl

use strict;
use warnings;

use Math::Prime::Util qw/lcm/;

my %h = ( L => 0, R => 1 );

my $steps = <>;
chomp $steps;
<>;

my @nodes;
my %map;
for my $line (<>) {
    chomp $line;
    my ($k, $l, $r) = $line =~ m/^(\w+) = \((\w+), (\w+)\)$/;
    $map{$k} = [ $l, $r ];
    push @nodes, $k if $k =~ m/A$/;
}

print lcm(map { solve($_) } @nodes) . "\n";

sub solve {
    my $k = shift;
    my $result = 0;
    my @steps = split //, $steps;
    while ($k !~ m/Z$/) {
        my $step = shift @steps;
        $k = $map{$k}->[$h{$step}];
        $result++;
        push @steps, $step;
    }
    return $result;
}
