#!/usr/bin/env perl

use strict;
use warnings;

my $safe = 0;

while (my $line = <>) {
    chomp $line;
    $safe++ if safe(split / /, $line);
}

print $safe . "\n";

sub safe {
    my @list = @_;

    for my $i (0..$#list) {
        my @l = map { $list[$_] } grep { $i != $_ } (0..$#list);
        return 1 if safe2(@l);
    }

    return 0;
}

sub safe2 {
    my @list = @_;

    my @x = map { $list[$_+1] - $list[$_] } (0..$#list-1);
    return 1 if $#list == grep { $_ >= 1 && $_ <= 3 } @x;
    return 1 if $#list == grep { $_ >= -3 && $_ <= -1 } @x;
    return 0;
}
