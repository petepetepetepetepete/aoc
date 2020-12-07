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

my $count = 0;
for my $c (keys %h) {
    $count++ if bag_contains($c, 'shiny gold');
}

print $count . "\n";

sub bag_contains {
    my ($bag, $needle) = @_;
    if ($h{$bag}{$needle}) {
        return 1;
    }
    for my $k (keys %{$h{$bag}}) {
        return 1 if bag_contains($k, $needle);
    }
    
    return 0;
}

