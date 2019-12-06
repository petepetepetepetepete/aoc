#!/usr/bin/env perl

use strict;
use warnings;

my %m;
while (my $line = <STDIN>) {
    chomp $line;
    my ($a, $b) = split/\)/, $line;
    $m{$b} = $a;
}

my $count = 0;
for my $k (sort keys %m) {
    $count += calculate_dist(\%m, $k, 'COM', 0);
}
print $count . "\n";

sub calculate_dist {
    my ($m, $a, $b, $res) = @_;

    return $res if $a eq $b;

    @_ = ($m, $m->{$a}, $b, ++$res);
    goto &calculate_dist;
}
