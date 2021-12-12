#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/uniq/;

my %map;
for my $pt (map { chomp; [ split /-/ ] } <>) {
    push @{$map{$pt->[0]}}, $pt->[1];
    push @{$map{$pt->[1]}}, $pt->[0];
}

print find_paths(\%map, 'start') . "\n";

sub find_paths {
    my ($m, $n, @p) = @_;
    return [@p, $n] if $n eq 'end';
    return if @p && $n eq 'start';
    return unless $n =~ m/^[A-Z]+$/ || !(grep { $n eq $_ } @p) || do { my @lc = grep { m/^[a-z]+$/ } @p; uniq(@lc) == scalar(@lc) };
    return map { find_paths($m, $_, @p, $n) } @{$m->{$n}};
}
