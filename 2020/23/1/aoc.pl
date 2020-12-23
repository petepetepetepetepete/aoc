#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/max/;

my $line = <>;
chomp $line;
my @cups = map { { value => $_ } } split //, $line;
my $max_cup = max(map { $_->{value} } @cups);

my %cups;
for my $i (reverse 0..$#cups) {
    $cups{$cups[$i]->{value}} = $cups[$i];
    $cups[$i]->{prev} = $cups[$i-1];
    $cups[$i-1]->{next} = $cups[$i];
}


sub step {
    my ($cup, $step) = @_;
    my $dest = $cup->{value} - 1;
    my $pick_head = $cup->{next};
    my $pick_tail = $pick_head->{next}->{next};

    my $node = $cups[0];
    #warn sprintf "-- move %d --\n", $step;
    #warn sprintf "cups (forward): %s\n", join(' ', map { my $c = $node; $node = $node->{next}; $c == $cup ? "($c->{value})" : $c->{value} } (0..$#cups));
    $node = $pick_head;
    #warn sprintf "pick up: %s\n", join(', ', map { my $c = $node; $node = $node->{next}; $c->{value} } (1..3));

    my $prev = $pick_head->{prev};
    my $next = $pick_tail->{next};

    $prev->{next} = $next;
    $next->{prev} = $prev;

    $pick_head->{prev} = $pick_tail->{next} = undef;

    $node = find_dest($cup, $pick_head, $dest);
    #warn sprintf "destination: %d\n\n", $dest;

    $prev = $node;
    $next = $node->{next};

    $prev->{next} = $pick_head;
    $pick_head->{prev} = $prev;

    $next->{prev} = $pick_tail;
    $pick_tail->{next} = $next;

    return $cup->{next};
}

sub find_dest {
    my ($cup, $pick, $dest) = @_;

    $dest = $max_cup if $dest == 0;

    my $node = $pick;
    if (grep { $_ == $dest } map { my $c = $node; $node = $node->{next}; $c->{value} } (1..3)) {
        return find_dest($cup, $pick, $dest-1);
    }

    return $cups{$dest};
}

my $node = $cups[0];
for my $i (1..100) {
    $node = step($node, $i);
}

($node) = grep { $_->{value} == 1 } @cups;
$node = $node->{next};

print join('', map { my $c = $node ; $node = $node->{next}; $c->{value} } (1..$#cups)) . "\n";
