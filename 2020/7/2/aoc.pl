#!/usr/bin/env perl

use strict;
use warnings;

my %h;
while (my $line = <>) {
    if ($line =~ m/([a-z ]+) bags contain /g) {
        my $outer_bag = $1;
        $h{$outer_bag} ||= {};
        while ($line =~ m/(\d+) ([a-z ]+) bags?[,.]/g) {
            my ($inner_bag, $count) = ($2, $1);
            $h{$outer_bag}{$inner_bag} ||= 0;
            $h{$outer_bag}{$inner_bag} += $count;
        }
    }
    else {
        die "Unexpected line: $line";
    }
}

my @colors = [ 'shiny gold', 1 ];

my $count = 0;
while (my $c = shift @colors) {
    $count += $c->[1];
    for my $k (keys %{$h{$c->[0]}}) {
        push @colors, [ $k, $c->[1] * $h{$c->[0]}{$k} ];
    }
}
$count--; # subtract the shiny gold bag

print $count . "\n";
