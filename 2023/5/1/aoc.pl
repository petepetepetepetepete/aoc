#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/min/;

my @seeds;
my %map;
my ($a, $b);
while (my $line = <>) {
    chomp $line;
    next if $line eq '';
    if ($line =~ m/^seeds: ([0-9 ]+)$/) {
        @seeds = split / +/, $1;
    }
    elsif ($line =~ m/^(\w+)-to-(\w+) map:/) {
        ($a, $b) = ($1, $2);
    }
    elsif ($line =~ m/^(\d+) (\d+) (\d+)$/) {
        $map{$a}{$b} //= [];
        push @{$map{$a}{$b}}, [ $1, $2, $3 ];
    }
    else {
        die $line;
    }
}

my @loc;
for my $seed (@seeds) {
    push @loc, solve($seed, 'seed', 'location');
}

print min(@loc) . "\n";

sub solve {
    my ($id, $src, $final_dst) = @_;

    if ($src eq $final_dst) {
        return $id;
    }

    my @dst = keys %{$map{$src}};
    use Data::Dumper;
    die Dumper \@dst unless @dst == 1;

    for my $entry (@{$map{$src}{$dst[0]}}) {
        if ($id >= $entry->[1] && $id < $entry->[1] + $entry->[2]) {
            my $new_id = $id + ($entry->[0] - $entry->[1]);
            return solve($new_id, $dst[0], $final_dst);
        }
    }

    return solve($id, $dst[0], $final_dst);
}
