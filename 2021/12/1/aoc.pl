#!/usr/bin/env perl

use strict;
use warnings;

my %map;
for my $pt (map { chomp; [ split /-/ ] } <>) {
    push @{$map{$pt->[0]}}, $pt->[1];
    push @{$map{$pt->[1]}}, $pt->[0];
}

print find_path_count(\%map, 'start') . "\n";;

sub find_path_count {
    my ($m, @p) = @_;

    return 1 if $p[-1] eq 'end';

    my $res = 0;
    $res += find_path_count($m, @p, $_) foreach grep { my $n = $_; m/^[A-Z]+$/ || !grep { $_ eq $n } @p } @{$m->{$p[-1]}};
    return $res;
}
