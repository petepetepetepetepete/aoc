#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

# J is now the lowest value card
my @cards = qw/J 2 3 4 5 6 7 8 9 T Q K A/;
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
    $cards{J} //= 0;

    # 5 of a kind
    if (@counts == 1) {
        $score += $hand_scores{5};
    }
    elsif (@counts == 2) {
        # 4 of a kind
        if ($counts[0] == 4) {
            if ($cards{J} >= 1) { # either 4J/1x or 4x/1J -> 5x
                $score += $hand_scores{5}; # 4 of a kind bumped to 5 of a kind
            }
            else {
                $score += $hand_scores{4};
            }
        }
        # full house
        elsif ($counts[0] == 3) {
            if ($cards{J} >= 2) { # either 3J/2x or 3x/2J -> 5x
                $score += $hand_scores{5}; # full house bumped to 5 of a kind
            }
            else {
                $score += $hand_scores{fh};
            }
        }
        else {
            die Dumper \@counts;
        }
    }
    elsif (@counts == 3) {
        # 3 of a kind
        if ($counts[0] == 3) {
            if ($cards{J} >= 1) { # either 3J/1x/1y or 3x/1J/1y -> 4x/1y
                $score += $hand_scores{4}; # 3 of a kind bumped to 4 of a kind
            }
            else {
                $score += $hand_scores{3};
            }
        }
        # 2 pair
        elsif ($counts[0] == 2) {
            if ($cards{J} == 2) { # 2J/2x/1y -> 4x/1y
                $score += $hand_scores{4}; # 2 pair bumped to 4 of a kind
            }
            elsif ($cards{J} == 1) { # 2x/2y/1J -> 3x/2y
                $score += $hand_scores{fh}; # 2 pair bumped to full house
            }
            else {
                $score += $hand_scores{'2p'};
            }
        }
        else {
            die Dumper \@counts;
        }
    }
    # 1 pair
    elsif (@counts == 4) {
        if ($cards{J} >= 1) { # 2J/1x/1y/1z or 2x/1J/1y/1z -> 3x/1y/1z
            $score += $hand_scores{3}; # 1 pair bumped to 3 of a kind
        }
        else {
            $score += $hand_scores{p};
        }
    }
    # high card
    else {
        if ($cards{J} == 1) { # 1J/1x/1y/1z/1a -> 2x/1y/1z/1a
            $score += $hand_scores{p}; # high card bumped to pair
        }
        else {
            $score += $hand_scores{h};
        }
    }

    return $score;
}
