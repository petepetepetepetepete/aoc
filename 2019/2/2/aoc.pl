#!/usr/bin/env perl

use strict;
use warnings;

my %opcodes = (
    1 => sub {
        my ($prog, $offset) = @_;
        $prog->[$prog->[$offset+3]] = $prog->[$prog->[$offset+1]] + $prog->[$prog->[$offset+2]];
        return 4;
    },
    2 => sub {
        my ($prog, $offset) = @_;
        $prog->[$prog->[$offset+3]] = $prog->[$prog->[$offset+1]] * $prog->[$prog->[$offset+2]];
        return 4;
    },
    99 => sub {
        my ($prog, $offset) = @_;
        return 0;
    }
);

my $input = <STDIN>;
chomp $input;


for my $noun (0..99) {
    for my $verb (0..99) {
        my @a = split /,/, $input;
        my $i = 0;

        $a[1] = $noun;
        $a[2] = $verb;

        while (1) {
            if (ref $opcodes{$a[$i]} eq 'CODE') {
                my $res = $opcodes{$a[$i]}->(\@a, $i);
                last unless $res;
                $i += $res;
            }
            else {
                die "Unknown opcode: $a[$i] at offset=$i";
            }
        }

        if ($a[0] == 19690720) {
            printf "%d\n", 100 * $noun + $verb;
            exit;
        }
    }
}

