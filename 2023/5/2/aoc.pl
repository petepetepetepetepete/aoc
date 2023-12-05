#!/usr/bin/env perl

use strict;
use warnings;

use Set::IntSpan;

use List::Util qw/pairs/;

my @seeds;
my %map;
my ($a, $b);

my $seed_set = Set::IntSpan->new;

while (my $line = <>) {
    chomp $line;
    next if $line eq '';
    if ($line =~ m/^seeds: ([0-9 ]+)$/) {
        for my $s (pairs(split / +/, $1)) {
            use Data::Dumper;
            $seed_set += Set::IntSpan->new(sprintf("%d-%d", $s->[0], $s->[0]+$s->[1]-1));
        }
    }
    elsif ($line =~ m/^(\w+)-to-(\w+) map:/) {
        ($a, $b) = ($1, $2);
    }
    elsif ($line =~ m/^(\d+) (\d+) (\d+)$/) {
        $map{$a}{$b} //= [];
        push @{$map{$a}{$b}}, [ Set::IntSpan->new(sprintf("%d-%d", $2, $2+$3-1)), $1-$2 ];
    }
    else {
        die $line;
    }
}

print solve($seed_set, 'seed', 'location') . "\n";

sub solve {
    my ($set, $src, $final_dst) = @_;

    if ($src eq $final_dst) {
        return $set->min();
    }

    my @dst = keys %{$map{$src}};
    use Data::Dumper;
    die Dumper \@dst unless @dst == 1;

    my $new_set = Set::IntSpan->new;
    my $diffset = Set::IntSpan->new;

    for my $entry (@{$map{$src}{$dst[0]}}) {
        my ($dst_set, $diff) = @$entry;
        my $interset = $dst_set * $set;
        $diffset += $interset;
        my @x = spans $interset;
        for my $x (@x) {
            $x->[0] += $diff;
            $x->[1] += $diff;
            $new_set += Set::IntSpan->new(sprintf("%d-%d", $x->[0], $x->[1]));
        }
    }
    $new_set += $set - $diffset;

    return solve($new_set, $dst[0], $final_dst);
}

