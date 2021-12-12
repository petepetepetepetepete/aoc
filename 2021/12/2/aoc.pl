#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/uniq/;

my %map;
for my $pt (map { chomp; [ split /-/ ] } <>) {
    push @{$map{$pt->[0]}}, $pt->[1];
    push @{$map{$pt->[1]}}, $pt->[0];
}

print find_path_counts(\%map, 'start') . "\n";

sub find_path_counts {
    my ($m, @p) = @_;

    return 1 if $p[-1] eq 'end';

    my $res = 0;
    for my $n (sort @{$m->{$p[-1]}}) {
        next if $n eq 'start';
        if (lc($n) eq $n && grep { $_ eq $n } @p) {
            my @lc = grep { lc($_) eq $_ } @p;
            next if uniq(@lc) < scalar(@lc);
        }
        $res += find_path_counts($m, @p, $n)
    }

    return $res;
}
