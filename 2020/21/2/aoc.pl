#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my %h;
my %i;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^([a-z ]+) \(contains ([a-z, ]+)\)$/) {
        my ($ingredients, $allergens) = ($1, $2);
        for my $ingredient (split / /, $ingredients) {
            $i{$ingredient}++;
            for my $allergen (split /, /, $allergens) {
                $h{$allergen}{$ingredient}++;
            }
        }
    }
    else {
        die "Unexpected line: $line";
    }
}

my %result;
while (keys %h) {
    my @a;
    my @b;
    for my $k (keys %h) {
        my @c = sort { $h{$k}{$b} <=> $h{$k}{$a} } keys %{$h{$k}};
        if (scalar(@c) == 1 || $h{$k}{$c[0]} > $h{$k}{$c[1]}) {
            $result{$c[0]} = $k;
            push @a, $k;
            push @b, $c[0];
        }
    }
    delete $h{$_} foreach @a;
    for my $k (keys %h) {
        delete $h{$k}{$_} foreach @b;
    }
    delete $i{$_} foreach @b;
}

print join(',', sort { $result{$a} cmp $result{$b} } keys %result) . "\n";
