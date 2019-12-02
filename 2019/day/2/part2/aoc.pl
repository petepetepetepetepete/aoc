#!/usr/bin/env perl

use strict;
use warnings;

my $input = <STDIN>;
chomp $input;

for my $noun (0..99) {
    for my $verb (0..99) {

        my @a = split /,/, $input;

        my $i = 0;

        $a[1] = $noun;
        $a[2] = $verb;

        while (1) {
            my $opcode = $a[$i];
            if ($opcode == 1) {
                $a[$a[$i+3]] = $a[$a[$i+1]] + $a[$a[$i+2]];
            }
            elsif ($opcode == 2) {
                $a[$a[$i+3]] = $a[$a[$i+1]] * $a[$a[$i+2]];
            }
            elsif ($opcode == 99) {
                last;
            }
            else {
                die "Unknown opcode: $opcode";
            }

            $i += 4;
        }

        if ($a[0] == 19690720) {
            print 100 * $noun + $verb;
            last;
        }
    }
}

print "\n";
