#!/usr/bin/env perl

use strict;
use warnings;

my $input = <STDIN>;
chomp $input;

my @a = split /,/, $input;

my $i = 0;

$a[1] = $ARGV[0] if defined $ARGV[0];
$a[2] = $ARGV[1] if defined $ARGV[1];

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

if (defined $ARGV[2]) {
    print $a[$ARGV[2]] . "\n";
}
else {
    print join(",", @a) . "\n";
}
