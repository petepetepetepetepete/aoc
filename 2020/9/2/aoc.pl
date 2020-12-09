#!/usr/bin/env perl

use strict;
use warnings;

my $preamble_length = shift || die "No preamble supplied";
my @numbers = map { chomp; $_ } <>;

my $target;
for my $i ($preamble_length..$#numbers) {
    if (!is_valid($numbers[$i], @numbers[$i-$preamble_length..$i-1])) {
        $target = $numbers[$i];
        last;
    }
}

for my $i (0..$#numbers) {
    my $res = solve($target, $i, \@numbers);
    if ($res) {
        print $res . "\n";
        last;
    }
}

sub solve {
    my ($target, $idx, $nums) = @_;
    my $sum = 0;
    my $min = $nums->[$idx];
    my $max = $min;

    for my $i ($idx..$#{$nums}) {
        $min = $nums->[$i] if $min < $nums->[$i];
        $max = $nums->[$i] if $max > $nums->[$i];
        $sum += $nums->[$i];
        return $min + $max if $sum == $target;
    }
    return;
}

sub is_valid {
    my ($num, @preamble) = @_;

    my %h = map { $num - $_ => 1 } @preamble;
    return grep { exists $h{$_} } @preamble;
}
