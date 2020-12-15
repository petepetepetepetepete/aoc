#!/usr/bin/env perl

use strict;
use warnings;

my $n = <>;
chomp $n;
my @n = split /,/, $n;
my %h = map { $n[$_] => $_+1 } (0..$#n-1);

my $last = $n[-1];
for my $i (scalar(@n)..2019) {
    if (exists $h{$last}) {
        my $next = $i - $h{$last};
        $h{$last} = $i;
        $last = $next;
    }
    else {
        $h{$last} = $i;
        $last = 0;
    }
}

print $last . "\n";

