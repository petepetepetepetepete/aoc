#!/usr/bin/env perl

use strict;
use warnings;

my @passports;

my %passport = ();
while (my $line = <>) {
    chomp $line;

    for my $pair (split / /, $line) {
        my ($k, $v) = split /:/, $pair;
        $passport{$k} = $v;
    }

    if ($line eq '') {
        push @passports, { %passport };
        %passport = ();
    }
}

if (scalar(keys %passport) > 0) {
    push @passports, \%passport;
}

my $count = 0;
my @req_keys = qw/byr iyr eyr hgt hcl ecl pid/;
for my $passport (@passports) {
    my $valid = 1;
    for my $k (@req_keys) {
        if (!exists $passport->{$k}) {
            $valid = 0;
            last;
        }
    }
    $count++ if $valid;
}
print "$count\n";
