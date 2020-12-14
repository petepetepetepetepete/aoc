#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @mask;
my %mem;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^mask = ([01X]+)$/) {
        @mask = reverse split //, $1;
    }
    elsif ($line =~ m/^mem\[(\d+)\] = (\d+)$/) {
        my ($addr, $val) = ($1, $2);
        for my $i (0..$#mask) {
            my $b = $mask[$i];
            if ($b eq '0') {
                $val &= ~(1 << $i);
            }
            elsif ($b eq '1') {
                $val |= (1 << $i);
            }
            elsif ($b ne 'X') {
                die "Unexpected bit: $b";
            }
        }
        $mem{$addr} = $val;
    }
    else {
        die "Unexpected line: $line\n";
    }
}

print sum(values %mem) . "\n";

