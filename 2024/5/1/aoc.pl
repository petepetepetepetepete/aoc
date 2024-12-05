#!/usr/bin/env perl

use strict;
use warnings;

my $input = do { local $/; <> };
my %rules;
for my $rule ($input =~ m/^(\d+\|\d+)$/gm) {
    my ($a, $b) = split /\|/, $rule;
    $rules{$b} //= [];
    push @{$rules{$b}}, $a; 
}

my $res = 0;
for my $update ($input =~ m/^([\d,]+)$/gm) {
    my @update = split /,/, $update;
    $res += score(@update) if valid(@update);
}

print $res . "\n";

sub valid {
    my @update = @_;

    for my $i (0..$#update) {
        my $n = $update[$i];
        return 0 if grep { my $m = $_; grep { $m == $_ } @{$rules{$n}} } map { $update[$_] } ($i+1..$#update);
    }

    return 1;
}

sub score {
    my @update = @_;
    return $update[$#update/2];
}
