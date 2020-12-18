#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @res;
while (my $line = <>) {
    chomp $line;
    push@res, solve($line);
}

print sum(@res) . "\n";

sub solve {
    my ($x) = @_;

    while ($x =~ m/\(/) {
        my $i = index($x, '(');
        my $n = 1;
        my @x = split //, $x;
        for my $j ($i+1..$#x) {
            $n++ if $x[$j] eq '(';
            $n-- if $x[$j] eq ')';
            if ($n == 0) {
                substr($x, $i, $j-$i+1) = solve(join('', @x[$i+1..$j-1]));
                last;
            }
        }
    }

    while ($x =~ s{(\d+ [+*] \d+)}{eval($1)}e) { }

    return $x;
}
