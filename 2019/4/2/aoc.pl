#!/usr/bin/env perl

use strict;
use warnings;

my $range = <>;
chomp $range;

my ($start, $end) = split /-/, $range;

my @valid_passwords = grep {
    length == 6 &&
    $_ == join('', sort(split //)) &&
    do {
        s/(\d)\1{2,}//g;
        m/(\d)\1/
    };
} ($start .. $end);

print scalar(@valid_passwords) . "\n";

