#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;
use MCE::Map;

my @records;
while (my $line = <>) {
    chomp $line;
    my ($r1, $r2) = split / /, $line;
    push @records, [ $r1, [ split /,/, $r2 ] ];
}

print sum(
    mce_map {
        my ($r1, $r2) = @$_;
        valid($r1, '', @$r2)
    } \@records
). "\n";

sub valid {
    my ($s, $t, @sizes) = @_;

    if (!@sizes) {
        if ($s =~ m/#/) {
            return 0;
        }
        else {
            return 1;
        }
    }

    $s =~ s/^\.*//;

    my $result = 0;
    my $size = shift @sizes;
    my $len = length($s);

    for my $i (0..$len) {
        my $s2 = $s;

        if ($s2 !~ s/^[?.]{$i}//) {
            last;
        }

        if ($s2 =~ s/^[#?]{$size}(?:[.?]|$)//) {
            $result += valid($s2, "$t\t", @sizes);
        }
    }

    return $result;
}
