#!/usr/bin/env perl

use strict;
use warnings;

sub get_param {
    my ($prog, $offset, $i) = @_;
    my $opcode = $prog->[$offset];
    return ($opcode / (10 ** ($i + 1))) % 10 ? $prog->[$offset+$i] : $prog->[$prog->[$offset+$i]];
}

my %opcodes = (
    1 => sub {
        my ($prog, $offset) = @_;
        $prog->[$prog->[$offset+3]] = get_param($prog, $offset, 1) + get_param($prog, $offset, 2);;
        return 4;
    },
    2 => sub {
        my ($prog, $offset) = @_;
        $prog->[$prog->[$offset+3]] = get_param($prog, $offset, 1) * get_param($prog, $offset, 2);;
        return 4;
    },
    3 => sub {
        my ($prog, $offset) = @_;
        my $input = <STDIN>;
        chomp $input;
        $prog->[$prog->[$offset+1]] = $input;
        return 2;
    },
    4 => sub {
        my ($prog, $offset) = @_;
        print get_param($prog, $offset, 1) . "\n";
        return 2;
    },
    99 => sub {
        my ($prog, $offset) = @_;
        return 0;
    }
);

open my $fh, "<$ARGV[0]" or die "Failed to open $ARGV[0] for read: $!";
my $input = <$fh>;
chomp $input;
close $fh;

my @a = split /,/, $input;
my $i = 0;

while (1) {
    my $opcode = $a[$i] % 100;

    if (ref $opcodes{$opcode} eq 'CODE') {
        my $res = $opcodes{$opcode}->(\@a, $i);
        last unless $res;
        $i += $res;
    }
    else {
        die "Unknown opcode: $opcode ($a[$i]) at offset=$i";
    }
}


