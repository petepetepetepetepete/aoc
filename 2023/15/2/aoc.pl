#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $line = <>;
chomp $line;

my @boxes = map { [] } (0..255);
hashmap($_) foreach split /,/, $line;

print sum(
    map {
        my $i = $_;
        my @slots = @{$boxes[$i]};
        map { ($i+1)*($_+1)*$slots[$_][1] } (0..$#slots)
    } (0..$#boxes)
) . "\n";

sub hashmap {
    my $s = shift;
    my ($label, $op, $fl) = $s =~ m/^([^=-]+)([=-])(\d*)$/;
    my $box = hash($label);

    if ($op eq '=') {
        die "No focal length?" unless defined $fl;
        my @i = grep { $boxes[$box][$_][0] eq $label } (0..$#{$boxes[$box]});
        if (@i) {
            $boxes[$box][$i[0]][1] = $fl;
        }
        else {
            push @{$boxes[$box]}, [$label, $fl];
        }
    }
    elsif ($op eq '-') {
        @{$boxes[$box]} = grep { $_->[0] ne $label } @{$boxes[$box]};
    }
    else {
        die "Unexpected operator: $op";
    }
}

sub hash {
    my $s = shift;
    my $cur = 0;
    for my $c (split //, $s) {
        $cur += ord($c);
        $cur *= 17;
        $cur %= 256;
    }
    return $cur;
}
