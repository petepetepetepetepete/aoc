#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/all/;
use Math::Prime::Util qw/lcm/;

my %ffm;
my %cm;
my @pulses = qw/-low -high/;

my $btnpushes = 0;
my %funcs = (
    output => sub {
        my ($src, $pulse) = @_;
        warn "$src $pulses[$pulse]-> output";
    },
    rx => sub {
        my ($src, $pulse) = @_;
        die $btnpushes if $pulse == 0; # this never happens :(
    },
);

# rx has pulses from the Conjunction `bn` which itself takes pulses from from
# the Conjunctions pl, mz, lz, and zm
# find the cycle length for each of these where they will send a low pulse
# The solution should be the lcm of those cycle lengths.
my %rx_inputs = (
    pl => [],
    mz => [],
    lz => [],
    zm => []
);

my @steps;
while (my $line = <>) {
    chomp $line;
    my ($name, $dests) = split / -> /, $line;
    my @dests = split/, /, $dests;
    my $prefix = '';
    if ($name =~ s/^([%&])//) {
        $prefix = $1;
    }

    # conjunction modules initially default to remembering a low pulse for each input
    for my $dest (@dests) {
        $cm{$dest}{$name} = 0;
    }

    # There is a single broadcast module (named broadcaster). When it receives a
    # pulse, it sends the same pulse to all # of its destination modules.
    if ($name eq 'broadcaster') {
        $funcs{$name} = sub {
            my ($src, $pulse) = @_;
            push @steps, [ $_, $name, $pulse ] foreach @dests;
            $btnpushes++;
        };
    }
    # Flip-flop modules (prefix %) are either on or off; they are initially off.
    # If a flip-flop module receives a high pulse, it is ignored and nothing
    # happens. However, if a flip-flop module receives a low pulse, it flips
    # between on and off. If it was off, it turns on and sends a high pulse. If
    # it was on, it turns off and sends a low pulse.
    elsif ($prefix eq '%') {
        $ffm{$name} = 0;

        $funcs{$name} = sub {
            my ($src, $pulse) = @_;
            if ($pulse == 1) {
                return;
            }
            die if $pulse != 0; # assume pulse can only be 0 or 1

            $ffm{$name} ^= 1;
            push @steps, [ $_, $name, $ffm{$name} ] foreach @dests;
        };
    }
    # Conjunction modules (prefix &) remember the type of the most recent pulse
    # received from each of their connected input modules; they initially
    # default to remembering a low pulse for each input. When a pulse is
    # received, the conjunction module first updates its memory for that input.
    # Then, if it remembers high pulses for all inputs, it sends a low pulse;
    # otherwise, it sends a high pulse
    elsif ($prefix eq '&') {
        $funcs{$name} = sub {
            my ($src, $pulse) = @_;

            $cm{$name}{$src} = $pulse;

            my $newpulse = 1;
            $newpulse &= $_ foreach values %{$cm{$name}};

            if ($name =~ m/^pl|mz|lz|zm$/ && $newpulse == 0) {
                push @{$rx_inputs{$name}}, $btnpushes;

                if (all { scalar(@$_) >= 2 } values %rx_inputs) {
                    print lcm(map { $_->[1] - $_->[0] } values %rx_inputs) . "\n";
                    exit 0;
                }
            }

            push @steps, [ $_, $name, $newpulse ^ 1 ] foreach @dests;
        };
    }
    else {
        die $line;
    }
}

while (1) {
    @steps = [ 'broadcaster', 'button', 0 ];
    while (my $step = shift @steps) {
        my ($f, $src, $pulse) = @$step;
        $funcs{$f}->($src, $pulse) if $funcs{$f};
    }
}

