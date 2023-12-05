#!/usr/bin/env perl

use strict;
use warnings;

my @numbers = qw/one two three four five six seven eight nine/;
my %numbers = map { $numbers[$_] => $_+1 } (0..$#numbers);
my $re = '(' . join('|', @numbers) . '|[0-9])';

my $result = 0;
while (my $line = <>) {
    chomp $line;
    my ($a, $b);
    if ($line =~ qr/^.*?${re}.*${re}/) {
        ($a, $b) = ($numbers{$1} // $1, $numbers{$2} // $2);
    }
    elsif ($line =~ qr/${re}/) {
        $a = $numbers{$1} // $1;
        $b = $a;
    }
    else {
        die "$line does not contain a digit";
    }

    $result += 10 * $a + $b;
}

print $result . "\n";

