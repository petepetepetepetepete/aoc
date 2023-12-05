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

print foo($seed_set, 'seed', 'location') . "\n";

sub foo {
    my ($set, $src, $final_dst) = @_;

    if ($src eq $final_dst) {
        return $set->min();
    }

    my @dst = keys %{$map{$src}};
    use Data::Dumper;
    die Dumper \@dst unless @dst == 1;
    #warn "$src->$dst[0]";
    #warn $set;

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
    #warn $new_set;

    return foo($new_set, $dst[0], $final_dst);
}

#my @loc;
#for my $seed (@seeds) {
#    push @loc, foo($seed->[0], $seed->[0] + $seed->[1] - 1, 'seed', 'location');
#}
#
#use Data::Dumper;
#warn Dumper \@loc;
#
#print min(map { $_->[0] } @loc) . "\n";
#
#sub foo {
#    my ($start_id, $end_id, $src, $final_dst) = @_;
#
#    if ($src eq $final_dst) {
#        return [ $start_id, $end_id ];
#    }
#
#    my @dst = keys %{$map{$src}};
#    use Data::Dumper;
#    die Dumper \@dst unless @dst == 1;
#
#    my $len = $end_id - $start_id + 1;
#    #warn "$start_id, $end_id($len), $src, $dst[0], $final_dst";
#    
#    my @res;
#    for my $entry (@{$map{$src}{$dst[0]}}) {
#        next if $start_id >= $entry->[1] + $entry->[2];
#        next if $end_id < $entry->[1];
#
#        my $start_diff = $start_id - $entry->[1];
#        my $end_diff = $entry->[1] + $entry->[2] - $end_id - 1;
#
#        $start_diff = 0 if $start_diff < 0;
#        $end_diff = 0 if $end_diff < 0;
#
#        if ($start_id < $entry->[1]) {
#            push @res, foo($start_id, $entry->[0] -1, $dst[0], $final_dst);
#        }
#
#        push @res, foo($entry->[0] + $start_diff, $entry->[0] + $entry->[2] - $end_diff - 1, $dst[0], $final_dst);
#
#        if ($end_id >= $entry->[1] + $entry->[2]) {
#            push @res, foo($entry->[1] + $entry->[2], $end_id, $dst[0], $final_dst);
#        }
#
#        #if ($id >= $entry->[1] && $id < $entry->[1] + $entry->[2]) {
#        #    my $new_id = $id + ($entry->[0] - $entry->[1]);
#        #    #warn $new_id;
#        #    return foo($new_id, $dst[0], $final_dst);
#        #}
#    }
#
#    push @res, foo($start_id, $end_id, $dst[0], $final_dst) unless @res;
#
#    return @res;
#}
