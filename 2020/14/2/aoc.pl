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
        for my $i (grep { $mask[$_] eq '1' } (0..$#mask)) {
            $addr |= (1 << $i);
        }
        my @x = grep { $mask[$_] eq 'X' } (0..$#mask);
        for my $i (0..2**scalar(@x)-1) {
            my $addr2 = $addr;
            for my $j (0..$#x) {
                if ($i & (1 << $j)) {
                    $addr2 |= (1 << $x[$j]);
                }
                else {
                    $addr2 &= ~(1 << $x[$j]);
                }
            }
            $mem{$addr2} = $val;
        }
    }
    else {
        die "Unexpected line: $line\n";
    }
}

print sum(values %mem) . "\n";

