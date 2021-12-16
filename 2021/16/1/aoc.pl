#!/usr/bin/env perl

use strict;
use warnings;

use bigint;

use List::Util qw/sum/;

my @c = map { chomp; [ map { split //, sprintf("%04b", hex($_)) } split // ] } <>;

my @pkt_func = map { \&operator } (0..7); $pkt_func[4] = \&literal;

print packet($c[0]) . "\n";

sub parse_bits {
    my ($c, $bits) = @_;
    my $res = '0b';
    $res .= shift @$c foreach (1..$bits);
    return oct($res);
}

sub packet {
    my $c = shift;
    my $version = parse_bits($c, 3);
    my $type = parse_bits($c, 3);
    return $version + $pkt_func[$type]->($c, $type);
}

sub literal {
    my $c = shift;
    my $res = '0b';
    while (@$c) {
        my $more = shift @$c;
        $res <<= 4;
        $res += parse_bits($c, 4);
        return 0 unless $more;
    }
}

sub operator {
    my $c = shift;
    my $length_type_id = shift @$c;
    my @versions;
    if ($length_type_id) {
        @versions = map { packet($c) } (1..parse_bits($c, 11));
    }
    else {
        my $rem = abs(parse_bits($c, 15) - scalar(@$c));
        while (scalar(@$c) > $rem) {
            push @versions, packet($c);
        }
    }

    return sum(@versions);
}
