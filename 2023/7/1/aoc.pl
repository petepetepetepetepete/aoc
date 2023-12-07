#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

my @cards = qw/2 3 4 5 6 7 8 9 T J Q K A/;
my %card_values = map { $cards[$_] => $_ + 1 } (0..$#cards);
my @hands = map { chomp; [ split / /, $_ ] } <>;
my %hand_scores = (
    '5'  => 64_000_000,
    '4'  => 32_000_000,
    'fh' => 16_000_000,
    '3'  =>  8_000_000,
    '2p' =>  4_000_000,
    'p'  =>  2_000_000,
    'h'  =>  1_000_000,
);

my @sorted_hands = sort { score($a->[0]) <=> score($b->[0]) } @hands;

my $result = 0;
for my $i (0..$#sorted_hands) {
    $result += ($i+1) * $sorted_hands[$i]->[1];
}

print $result . "\n";

sub score {
    my $hand = shift;

    my $score = 0;
    my @cards = reverse split //, $hand;
    for my $i (0..$#cards) {
        my $val = $card_values{$cards[$i]};
        $score += $val * 13 ** $i;
    }

    my %cards;
    $cards{$_}++ foreach @cards;

    my @counts = reverse sort values %cards;
    # 5 of a kind
    if (@counts == 1) {
        $score += $hand_scores{5};
    }
    elsif (@counts == 2) {
        # 4 of a kind
        if ($counts[0] == 4) {
            $score += $hand_scores{4};
        }
        # full house
        elsif ($counts[0] == 3) {
            $score += $hand_scores{fh};
        }
        else {
            die Dumper \@counts;
        }
    }
    elsif (@counts == 3) {
        # 3 of a kind
        if ($counts[0] == 3) {
            $score += $hand_scores{3};
        }
        # 2 pair
        elsif ($counts[0] == 2) {
            $score += $hand_scores{'2p'};
        }
        else {
            die Dumper \@counts;
        }
    }
    # 1 pair
    elsif (@counts == 4) {
        $score += $hand_scores{p};
    }
    # high card
    else {
        $score += $hand_scores{h};
    }

    return $score;
}
