#!/usr/bin/env perl

use strict;
use warnings;

my $preamble_length = shift || die "No preamble supplied";
my @numbers = map { chomp; $_ } <>;

for my $i ($preamble_length..$#numbers) {
    if (!is_valid($numbers[$i], @numbers[$i-$preamble_length..$i-1])) {
        print $numbers[$i] ."\n";
        last;
    }
}

sub is_valid {
    my ($num, @preamble) = @_;

    my %h = map { $num - $_ => 1 } @preamble;
    return grep { exists $h{$_} } @preamble;
}
