#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min/;

my %m;
while (my $line = <STDIN>) {
    chomp $line;
    my ($a, $b) = split/\)/, $line;
    $m{$b} = $a;
}

my @distances;
for my $k (sort keys %m) {
    my $a = calculate_dist(\%m, $m{YOU}, $k, 0); next if $a < 0;
    my $b = calculate_dist(\%m, $m{SAN}, $k, 0); next if $b < 0;
    push @distances, $a + $b;
}

print min(@distances) . "\n";

sub calculate_dist {
    my ($m, $a, $b, $res) = @_;

    return $res if $a eq $b;
    return -1 unless defined $m->{$a};

    @_ = ($m, $m->{$a}, $b, ++$res);
    goto &calculate_dist;
}
