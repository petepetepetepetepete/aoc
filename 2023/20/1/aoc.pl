#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/all/;

my %ffm;
my %cm;
my @pulses = qw/-low -high/;

my %funcs = (
    output => sub {
        my ($src, $pulse) = @_;
        warn "$src $pulses[$pulse]-> output";
    }
);

my @steps;
my @result;
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
            #warn "$src $pulses[$pulse]-> $name";
            push @steps, [ $_, $name, $pulse ] foreach @dests;
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
            #warn "$src $pulses[$pulse]-> $name";
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
            #warn "$src $pulses[$pulse]-> $name";

            $cm{$name}{$src} = $pulse;

            my $newpulse = 1;
            $newpulse &= $_ foreach values %{$cm{$name}};

            push @steps, [ $_, $name, $newpulse ^ 1 ] foreach @dests;
        };
    }
    else {
        die $line;
    }
}

for my $i (1..1000) {
    @steps = [ 'broadcaster', 'button', 0 ];
    while (my $step = shift @steps) {
        my ($f, $src, $pulse) = @$step;
        $result[$pulse]++;
        $funcs{$f}->($src, $pulse) if $funcs{$f};
    }
}

print $result[0] * $result[1] . "\n";
