#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my %h;
my $player;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^Player (\d):$/) {
        $player = $1;
        $h{$player} ||= [];
    }
    elsif ($line =~ m/(\d+)/) {
        push @{$h{$player}}, $1;
    }
    elsif ($line ne '') {
        die "Unexpected line: $line";
    }
}

my $round = 1;
my @players = sort keys %h;
while (!grep { scalar(@$_) == 0 } values %h) {
    #warn sprintf "-- Round %d --\n", $round++;
    for my $p (@players) {
        #warn sprintf "Player %d's deck: %s\n", $p, join(', ', @{$h{$p}});
    }
    my @cards;
    for my $p (@players) {
        push @cards, shift @{$h{$p}};
        #warn sprintf "Player %d plays: %d\n", $p, $cards[-1];
    }

    if ($cards[0] > $cards[1]) {
        #warn sprintf "Player %d wins the round!\n", $players[0];
        push @{$h{$players[0]}}, @cards;
    }
    elsif ($cards[1] > $cards[0]) {
        #warn sprintf "Player %d wins the round!\n", $players[1];
        push @{$h{$players[1]}}, reverse @cards;
    }
    else {
        #warn "Cards are equal: $cards[0]";
    }
    #warn "\n";
}

#warn "== Post-game results ==\n";
for my $p (@players) {
    #warn sprintf "Player %d's deck: %s\n", $p, join(', ', @{$h{$p}});
}

my ($winning_player) = grep { scalar(@{$h{$_}}) > 0 } @players;

my $i = 1;
print sum(map { $i++ * $_ } reverse @{$h{$winning_player}}) . "\n";
