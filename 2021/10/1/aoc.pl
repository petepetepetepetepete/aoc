#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my %score = ( ')' => 3, ']' => 57, '}' => 1197, '>' => 25137 );
my %r = ( ')' => '(', ']' => '[', '}' => '{', '>' => '<' );

print sum(map { chomp; score(split //) } <>) . "\n";

sub score {
    for my $i (0..$#_) {
        next if $_[$i] =~ m/[([{<]/;
        return $_[$i-1] eq $r{$_[$i]} ? score(@_[0..$i-2,$i+1..$#_]) : $score{$_[$i]};
    }
    return 0;
}
