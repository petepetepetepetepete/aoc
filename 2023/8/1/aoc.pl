#!/usr/bin/env perl

use strict;
use warnings;

my %h = ( L => 0, R => 1 );

my $steps = <>;
chomp $steps;
<>;

my %map;
for my $line (<>) {
    chomp $line;
    my ($k, $l, $r) = $line =~ m/^(\w+) = \((\w+), (\w+)\)$/;
    $map{$k} = [ $l, $r ];
}

print solve('AAA') . "\n";

sub solve {
    my $k = shift;
    my $result = 0;
    my @steps = split //, $steps;
    while ($k ne 'ZZZ') {
        my $step = shift @steps;
        $k = $map{$k}->[$h{$step}];
        $result++;
        push @steps, $step;
    }
    return $result;
}
