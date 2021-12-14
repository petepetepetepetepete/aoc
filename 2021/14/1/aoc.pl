#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min max/;

my $poly;
my %map;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^(\w+) -> (\w)$/) {
        $map{$1} = $2;
    }
    elsif ($line ne '') {
        $poly = $line;
    }
}
print val($poly, 10) . "\n";

sub val {
    my ($poly, $i) = @_;
    my @a = split //, $poly;
    my %pairs;
    $pairs{$_}++ foreach map { join('', @a[$_,$_+1])  } (0..$#a-1);
    my %chars;
    $chars{$_}++ foreach @a;

    while ($i--) {
        my %tmp = ();
        for my $p (keys %pairs) {
            if (exists $map{$p}) {
                my @b = split //, $p;
                $tmp{$b[0].$map{$p}} += $pairs{$p};
                $tmp{$map{$p}.$b[1]} += $pairs{$p};
                $chars{$map{$p}} += $pairs{$p};
            }
        }
        %pairs = %tmp;
    }

    my $min;
    my $max;
    for my $v (values %chars) {
        $min //= $v;
        $max //= $v;
        $min = min($min, $v);
        $max = max($max, $v);
    }

    return $max-$min;
}

