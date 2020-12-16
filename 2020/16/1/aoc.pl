#!/usr/bin/env perl

use strict;
use warnings;

my %rules;

# rules
while (my $line = <>) {
    chomp $line;
    last if $line eq '';
    if ($line =~ m/^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)$/) {
        my ($a, $b, $c, $d) = ($2, $3, $4, $5);
        $rules{$1} = sub {
            my $n = shift;
            return ($n >= $a && $n <= $b) || ($n >= $c && $n <= $d);
        };
    }
    else {
        die "Unexpected line: $line";
    }
}

# my ticket (ignore for now)
while (my $line = <>) {
    chomp $line;
    next if $line eq 'your ticket:';
    last if $line eq '';
}

my $res = 0;
# nearby ticket
while (my $line = <>) {
    chomp $line;
    next if $line eq 'nearby tickets:';
    last if $line eq '';
    for my $n (split /,/, $line) {
        my $valid = 0;
        for my $k (keys %rules) {
            if ($rules{$k}->($n)) {
                $valid = 1;
                last;
            }

        }
        $res += $n unless $valid;
    }
}

print $res . "\n";

