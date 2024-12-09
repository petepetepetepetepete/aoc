#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/first sum/;

my $in = do { local $/; <> };
chomp $in;

my $id = 0;
my @map;
while ($in =~ m/(\d{1,2})/g) {
    my ($a,$b) = split //, $1;
    push @map, {
        id => $id++,
        size => $a,
    };
    push @map, {
        id => -1,
        size => $b,
    } if $b;
}

for (my $j = $#map; $j >= 0; $j--) {
    next if $map[$j]{id} == -1;

    my $i = first { $map[$_]{id} == -1 && $map[$_]{size} >= $map[$j]{size} } (0..$j-1);
    next unless defined $i;

    my $id = $map[$j]{id};
    my $rem = $map[$i]{size} - $map[$j]{size};
    if ($rem >= 0) {
        $map[$j]{id} = -1;
        $map[$i]{id} = $id;

        if ($rem > 0) {
            $map[$i]{size} = $map[$j]{size};
            if ($map[$i+1]{id} == -1) {
                $map[$i+1]{size} += $rem;
            }
            else {
                splice(@map, $i+1, 0, { id => -1, size => $rem });
                $j++;
            }
        }
    }
}

my $n = 0;
print sum(map { my $p = $_; map { $n++ * (($p->{id} == -1) ? 0 : $p->{id}) } (1..$p->{size}) } @map) . "\n";
