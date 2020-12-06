#!/usr/bin/env perl

use strict;
use warnings;

my @answers;
my %h = ();
while (my $line = <>) {
    chomp $line;
    
    if ($line =~ m/^$/) {
        push @answers, { %h };
        %h = ();
        next;
    }

    $h{COUNT}++;
    for my $c (split //, $line) {
        $h{$c}++;
    }
}

if (scalar(keys %h) > 0) {
    push @answers, { %h };
}

my $res = 0;
for my $a (@answers) {
    for my $k (keys %$a) {
        next if $k eq 'COUNT';
        $res++ if $a->{$k} == $a->{COUNT};
    }
}

print "$res\n";
