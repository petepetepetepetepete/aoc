#!/usr/bin/env perl

use strict;
use warnings;

my $range = <>;
chomp $range;

my ($start, $end) = split /-/, $range;

my @valid_passwords = grep {
    length == 6 &&
    m/(\d)\1/ &&
    $_ == join('', sort(split //))
} ($start .. $end);

print scalar(@valid_passwords) . "\n";

