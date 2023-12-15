#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $line = <>;
chomp $line;

print sum(map { hash($_) } split /,/, $line) . "\n";

sub hash {
    my $s = shift;
    my $cur = 0;
    for my $c (split //, $s) {
        $cur += ord($c);
        $cur *= 17;
        $cur %= 256;
    }
    return $cur;
}
