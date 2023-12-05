#!/usr/bin/env perl

use strict;
use warnings;

use Carp;

use List::Util qw/min max/;

my @seeds;
my %map;
my ($a, $b);
while (my $line = <>) {
    chomp $line;
    next if $line eq '';
    if ($line =~ m/^seeds: ([0-9 ]+)$/) {
        my @s = split / +/, $1;
        for (my $i = 0; $i < $#s; $i += 2) {
            push @seeds, [ $s[$i], $s[$i+1] ];
        }
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
    push @loc, foo($seed->[0], $seed->[0] + $seed->[1] - 1, 'seed', 'location');
}

use Data::Dumper;
warn Dumper \@loc;

print min(map { $_->[0] } @loc) . "\n";

sub foo {
    my ($start_id, $end_id, $src, $final_dst) = @_;

    if ($src eq $final_dst) {
        return [ $start_id, $end_id ];
    }

    my @dst = keys %{$map{$src}};
    use Data::Dumper;
    die Dumper \@dst unless @dst == 1;

    my $len = $end_id - $start_id + 1;
    #warn "$start_id, $end_id($len), $src, $dst[0], $final_dst";
    
    my @res;
    for my $entry (@{$map{$src}{$dst[0]}}) {
        next if $start_id >= $entry->[1] + $entry->[2];
        next if $end_id < $entry->[1];

        my $start_diff = $start_id - $entry->[1];
        my $end_diff = $entry->[1] + $entry->[2] - $end_id - 1;

        $start_diff = 0 if $start_diff < 0;
        $end_diff = 0 if $end_diff < 0;

        if ($start_id < $entry->[1]) {
            push @res, foo($start_id, $entry->[0] -1, $dst[0], $final_dst);
        }

        push @res, foo($entry->[0] + $start_diff, $entry->[0] + $entry->[2] - $end_diff - 1, $dst[0], $final_dst);

        if ($end_id >= $entry->[1] + $entry->[2]) {
            push @res, foo($entry->[1] + $entry->[2], $end_id, $dst[0], $final_dst);
        }

        #if ($id >= $entry->[1] && $id < $entry->[1] + $entry->[2]) {
        #    my $new_id = $id + ($entry->[0] - $entry->[1]);
        #    #warn $new_id;
        #    return foo($new_id, $dst[0], $final_dst);
        #}
    }

    push @res, foo($start_id, $end_id, $dst[0], $final_dst) unless @res;

    return @res;
}
