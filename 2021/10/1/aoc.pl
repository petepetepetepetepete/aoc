#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my %score = ( ')' => 3, ']' => 57, '}' => 1197, '>' => 25137 );
my %r = ( ')' => '(', ']' => '[', '}' => '{', '>' => '<' );

print sum(map { chomp; score(split //) } <>) . "\n";

sub score {
    my @a = @_;
    for my $i (0..$#a) {
        next if $a[$i] =~ m/[([{<]/;
        return $a[$i-1] eq $r{$a[$i]} ? score(@a[0..$i-2,$i+1..$#a]) : $score{$a[$i]};
    }
    return 0;
}
