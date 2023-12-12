#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;
use MCE::Map;

my @c = ('.', '#');
my @records;
while (my $line = <>) {
    chomp $line;
    my ($r1, $r2) = split / /, $line;
    push @records, [ [ split //, $r1 ], [ split /,/, $r2 ] ];
}

print sum(
    mce_map {
        my ($r1, $r2) = @$_;
        solve($r1, $r2)
    } \@records
). "\n";

sub solve {
    my ($r1, $r2) = @_;

    my @q = grep { $_ eq '?' } @$r1;
    return 1 unless @q;

    my $x = 2**@q;

    my $count = sum(@$r2) - grep { $_ eq '#' } @$r1;

    my $result = 0;
    for my $i (0..$x-1) {
        my @r = @$r1;
        my $mask = $i;

        next unless $count == unpack("%b*", pack("V", $i));

        for my $j (reverse 0..$#r) {
            next unless $r[$j] eq '?';

            $r[$j] = $c[$mask & 0x1];
            $mask >>= 1;
        }

        my @blocks = map { length($_) } grep { $_ ne '' } split /\.+/, join('', @r);
        $result++ if @blocks == @$r2 && join(',', @blocks) eq join(',', @$r2);
    }

    return $result;
}

