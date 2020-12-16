#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/product/;

my %rules;

sub is_ticket_valid {
    my $t = shift;

    for my $n (split /,/, $t) {
        my $valid = 0;
        for my $k (keys %rules) {
            if ($rules{$k}{func}->($n)) {
                $valid = 1;
                last;
            }
        }
        return 0 unless $valid;
    }

    return 1;
}

# rules
while (my $line = <>) {
    chomp $line;
    last if $line eq '';
    if ($line =~ m/^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)$/) {
        my ($f, $a, $b, $c, $d) = ($1, $2, $3, $4, $5);
        $rules{$f}{func} = sub {
            my $n = shift;
            return ($n >= $a && $n <= $b) || ($n >= $c && $n <= $d);
        };
    }
    else {
        die "Unexpected line: $line";
    }
}

my $s = <>;
die unless $s =~ m/^your ticket:/;

$s = <>;
chomp $s;

my @ticket = split /,/, $s;

$s = <>;
chomp $s;
die unless $s eq '';
$s = <>;
die unless $s =~ m/^nearby tickets:/;

my @valid;
# nearby ticket
while (my $line = <>) {
    chomp $line;
    last if $line eq '';
    push @valid, [ split /,/, $line ] if is_ticket_valid($line);
}

for my $i (0..$#{$valid[0]}) {
    for my $k (keys %rules) {
        if (scalar(grep { $rules{$k}{func}->($_) } map { $_->[$i] } @valid) == scalar(@valid)) {
            push @{$rules{$k}{idx}}, $i;
        }
    }
}

while (grep { scalar(@{$_->{idx}}) > 1 } values %rules) {
    for my $r (grep { @{$_->{idx}} == 1 } values %rules) {
        for my $r2 (grep { @{$_->{idx}} > 1 && grep { $_ == $r->{idx}[0] } @{$_->{idx}} } values %rules) {
            my ($idx) = grep { $r2->{idx}[$_] == $r->{idx}[0] } (0..$#{$r2->{idx}});
            splice @{$r2->{idx}}, $idx, 1;
        }
    }
}
print product(map { $ticket[$rules{$_}{idx}[0]] } grep { m/^departure/ } keys %rules) . "\n";

