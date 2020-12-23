#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;
use List::Util qw/max sum/;

my %in;
my $player;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/^Player (\d):$/) {
        $player = $1;
        $in{players}{$player} ||= [];
    }
    elsif ($line =~ m/(\d+)/) {
        push @{$in{players}{$player}}, $1;
    }
    elsif ($line ne '') {
        die "Unexpected line: $line";
    }
}

my @players = sort keys %{$in{players}};

sub play_game {
    my ($h, $g) = @_;

    my $cur_game = $g;
    my $next_game = $g+1;
    #warn sprintf "=== Game %d ===\n\n", $cur_game;

    my $round = 1;
    my $winner;
    while (!defined $winner) {
        #warn sprintf "-- Round %d (Game %d) --\n", $round++, $cur_game;
        for my $p (@players) {
            #warn sprintf "Player %d's deck: %s\n", $p, join(', ', @{$h->{players}{$p}});
        }
        my @cards;
        for my $p (@players) {
            push @cards, shift @{$h->{players}{$p}};
            #warn sprintf "Player %d plays: %d\n", $p, $cards[-1];
        }

        my $round_winner = round_winner($h, \@players, \@cards);
        if (!defined $round_winner) {
            #warn "Playing a sub-game to determine the winner...\n\n";
            my %h2;
            for my $i (0..$#players) {
                $h2{players}{$players[$i]} = [ @{$h->{players}{$players[$i]}}[0..$cards[$i]-1] ];
            }
            $round_winner = play_game(\%h2, $next_game++);
            #warn sprintf"...anyway, back to game %d.\n", $cur_game;
        }

        if ($round_winner == 0) {
            #warn sprintf "Player %d wins round %d of game %d!\n", $players[0], $round-1, $cur_game;
            push @{$h->{players}{$players[0]}}, @cards;
        }
        elsif ($round_winner == 1) {
            #warn sprintf "Player %d wins round %d of game %d!\n", $players[1], $round-1, $cur_game;
            push @{$h->{players}{$players[1]}}, reverse @cards;
        }

        #warn "\n";
        $winner = game_winner($h);
    }

    #my $winner = game_winner($h);
    if ($cur_game == 1) {
        #warn "== Post-game results ==\n";
        for my $p (@players) {
            #warn sprintf "Player %d's deck: %s\n", $p, join(', ', @{$h->{players}{$p}});
        }
    }
    else {
        #warn sprintf "The winner of game %d is player %d!\n", $cur_game, $players[$winner];
    }

    return $winner;
}

sub round_winner {
    my ($h, $p, $c) = @_;

    my @a = grep { $c->[$_] <= scalar(@{$h->{players}{$p->[$_]}}) } (0..$#{$p});
    if (scalar(@a) == 2) {
        return undef;
    }

    return (sort { $c->[$b] <=> $c->[$a] } (0..$#{$c}))[0];
}

sub game_winner {
    my ($h) = @_;

    my $state = join '|', map { join ',', @{$h->{players}{$_}} } sort keys %{$h->{players}};
    if (exists $h->{previous_states}{$state}) {
        my ($i) = grep { $players[$_] == 1 } (0..$#players);
        return $i;
    }
    $h->{previous_states}{$state}++;

    if (grep { scalar(@$_) == 0 } values %{$h->{players}}) {
        return (grep { scalar(@{$h->{players}{$players[$_]}}) > 0 } (0..$#players))[0];
    }

    return undef;
}

my $winning_player = $players[play_game(\%in, 1)];
my $i = 1;
print sum(map { $i++ * $_ } reverse @{$in{players}{$winning_player}}) . "\n";

