#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $n = 1;
my %score = map { $_ => $n++ } qw/( [ { </;
my %r = ( ')' => '(', ']' => '[', '}' => '{', '>' => '<' );

my @scores = sort { $a <=> $b } grep { defined } map { chomp; score(split //) } <>;
print $scores[scalar(@scores)/2] . "\n";

sub score {
    my @a = @_;
    for my $i (0..$#a) {
        next if $a[$i] =~ m/[([{<]/;
        return $a[$i-1] eq $r{$a[$i]} ? score(@a[0..$i-2,$i+1..$#a]) : undef;
    }
    return sum(map { $score{$a[$_]} * 5**$_ } reverse (0..$#a));
}
