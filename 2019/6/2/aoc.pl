#!/usr/bin/env perl

use strict;
use warnings;

my %m = map { chomp; my ($a, $b) = split /\)/; $b => $a } <STDIN>;

my $dist = 999_999_999;
for my $k (sort keys %m) {
    my $a = calculate_dist(\%m, $m{YOU}, $k, 0); next if $a < 0;
    my $b = calculate_dist(\%m, $m{SAN}, $k, 0); next if $b < 0;
    $dist = $dist < $a + $b ? $dist : $a + $b;
}
print "$dist\n";

sub calculate_dist {
    my ($m, $a, $b, $res) = @_;

    return $res if $a eq $b;
    return -1 unless defined $m->{$a};

    @_ = ($m, $m->{$a}, $b, ++$res);
    goto &calculate_dist;
}
