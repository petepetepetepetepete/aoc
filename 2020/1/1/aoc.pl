#!/usr/bin/env perl

use strict;
use warnings;

my %h;
while (my $line = <>) {
    chomp $line;

    if (exists $h{$line}) {
        print $line * $h{$line} . "\n";
        last;
    }

    my $req = 2020 - $line;
    $h{$req} = $line;
}

