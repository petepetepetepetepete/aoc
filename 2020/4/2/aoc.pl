#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'numeric';

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
    $count++ if valid_passport($passport);
}
print "$count\n";

sub valid_passport {
    my $p = shift;

    return 0 if (!exists $p->{byr} || $p->{byr} < 1920 || $p->{byr} > 2002);
    return 0 if (!exists $p->{iyr} || $p->{iyr} < 2010 || $p->{iyr} > 2020);
    return 0 if (!exists $p->{eyr} || $p->{eyr} < 2020 || $p->{eyr} > 2030);
    return 0 if (!exists $p->{hgt} || $p->{hgt} !~ m/cm|in/ || ($p->{hgt} =~ m/cm/ && ($p->{hgt} < 150 || $p->{hgt} > 193)) || ($p->{hgt} =~ m/in/ && ($p->{hgt} < 59 || $p->{hgt} > 76)));
    return 0 if (!exists $p->{hcl} || $p->{hcl} !~ m/^#[0-9a-f]{6}$/);
    return 0 if (!exists $p->{ecl} || $p->{ecl} !~ m/^(?:amb|blu|brn|gry|grn|hzl|oth)$/);
    return 0 if (!exists $p->{pid} || $p->{pid} !~ m/^[0-9]{9}$/);

    return 1;
}
