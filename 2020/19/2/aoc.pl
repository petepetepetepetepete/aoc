#!/usr/bin/env perl

use strict;
use warnings;

my %rules;
while (my $line = <>) {
    chomp $line;
    last if $line eq '';
    if ($line =~ m/^(\d+): (.*)$/) {
        $rules{$1} = $2;
    }
    else {
        die "Unexpected rule: $line";
    }
}

my $regex = build_re(0);

sub build_re {
    my ($id) = @_;

    my $re = '';
    if ($id == 8) {
        $re = '(?:' . build_re(42) . ')+';
    }
    elsif ($id == 11) {
        $re = '(' . build_re(42) . '(?1)?' . build_re(31) . ')';
    }
    elsif ($rules{$id} =~ m/^"([a-z])"$/) {
        $re .= $1;
    }
    elsif ($rules{$id} =~ m/^([0-9 ]+)$/) {
        for my $i (split / /, $1) {
            $re .= build_re($i);
        }
    }
    elsif ($rules{$id} =~ m/^([0-9 ]+) \| ([0-9 ]+)$/) {
        my ($a, $b) = ($1, $2);
        $re .= '(?:';
        for my $i (split / /, $a) {
            $re .= build_re($i);
        }
        $re .= '|';
        for my $i (split / /, $b) {
            $re .= build_re($i);
        }
        $re .= ')';
    }
    else {
        die "Unexpected rule: $rules{$id}";
    }

    return $re;
}

my $match = 0;
while (my $line = <>) {
    chomp $line;
    $match++ if $line =~ qr/^$regex$/;
}

print $match . "\n";
