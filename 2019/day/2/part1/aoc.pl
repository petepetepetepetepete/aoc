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

my @a = split /,/, $input;

my $i = 0;

$a[1] = $ARGV[0] if defined $ARGV[0];
$a[2] = $ARGV[1] if defined $ARGV[1];

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

if (defined $ARGV[2]) {
    print $a[$ARGV[2]] . "\n";
}
else {
    print join(",", @a) . "\n";
}
