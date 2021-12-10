#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $n = 1;
my %score = map { $_ => $n++ } qw/( [ { </;
my %r = qw/) ( ] [ } { > </;

my @scores = sort { $a <=> $b } grep { defined } map { chomp; score(split //) } <>;
print $scores[scalar(@scores)/2] . "\n";

sub score {
    for my $i (0..$#_) {
        next if $_[$i] =~ m/[([{<]/;
        return $_[$i-1] eq $r{$_[$i]} ? score(@_[0..$i-2,$i+1..$#_]) : undef;
    }
    return sum(map { $score{$_[$_]} * 5**$_ } reverse (0..$#_));
}
