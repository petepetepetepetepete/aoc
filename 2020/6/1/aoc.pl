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

    for my $c (split //, $line) {
        $h{$c}++;
    }
}

if (scalar(keys %h) > 0) {
    push @answers, { %h };
}

my $res = 0;
for my $a (@answers) {
    $res += scalar(keys %$a);
}

print "$res\n";
