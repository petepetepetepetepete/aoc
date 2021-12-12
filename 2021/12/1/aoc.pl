#!/usr/bin/env perl

use strict;
use warnings;

my %map;
for my $pt (map { chomp; [ split /-/ ] } <>) {
    push @{$map{$pt->[0]}}, $pt->[1];
    push @{$map{$pt->[1]}}, $pt->[0];
}

print find_paths(\%map, 'start') . "\n";

sub find_paths {
    my ($m, $n, @p) = @_;
    return [@p, $n] if $n eq 'end';
    return unless $n =~ m/^[A-Z]+$/ || !grep { $n eq $_ } @p;
    return map { find_paths($m, $_, @p, $n) } @{$m->{$n}};
}
