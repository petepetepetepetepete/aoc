#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;
use List::Util qw/min max/;

my %m;

my %min = map { $_ => 0 } qw/x y z w/;
my %max = map { $_ => 0 } qw/x y z w/;

while (my $line = <>) {
    chomp $line;
    my @c = split //, $line;
    $max{x} = $#c;
    for my $x (0..$#c) {
        $m{$max{w}}{$max{z}}{$max{y}}{$x} = $c[$x];
    }
    $max{y}++;
}
$max{y}--;

for my $i (1..6) {
    step(\%m);
}

print active_count(\%m) . "\n";

sub step {
    my $map = shift;

    my $m2 = dclone($map);
    for my $w ($min{w}-1..$max{w}+1) {
        for my $z ($min{z}-1..$max{z}+1) {
            for my $y ($min{y}-1..$max{y}+1) {
                for my $x ($min{x}-1..$max{x}+1) {
                    my $c = calc($m2, $x, $y, $z, $w);
                    if (defined $c) {
                        $map->{$w}{$z}{$y}{$x} = $c;
                        $min{x} = min($min{x}, $x);
                        $max{x} = max($max{x}, $x);
                        $min{y} = min($min{y}, $y);
                        $max{y} = max($max{y}, $y);
                        $min{z} = min($min{z}, $z);
                        $max{z} = max($max{z}, $z);
                        $min{w} = min($min{w}, $w);
                        $max{w} = max($max{w}, $w);
                    }
                }
            }
        }
    }
}

sub calc {
    my ($map, $x, $y, $z, $w) = @_;
    my $active = 0;
    for my $w2 ($w-1..$w+1) {
        next unless exists $map->{$w2};
        for my $z2 ($z-1..$z+1) {
            next unless exists $map->{$w2}{$z2};
            for my $y2 ($y-1..$y+1) {
                next unless exists $map->{$w2}{$z2}{$y2};
                for my $x2 ($x-1..$x+1) {
                    next unless exists $map->{$w2}{$z2}{$y2}{$x2};
                    next if $x == $x2 && $y == $y2 && $z == $z2 && $w == $w2;
                    $active++ if $map->{$w2}{$z2}{$y2}{$x2} eq '#';
                }
            }
        }
    }

    if (($map->{$w}{$z}{$y}{$x} // '.') eq '#' && ($active < 2 || $active > 3)) {
        return '.';
    }
    elsif (($map->{$w}{$z}{$y}{$x} // '.') eq '.' && $active == 3) {
        return '#';
    }

    return $map->{$w}{$z}{$y}{$x};
}

sub active_count {
    my $map = shift;
    my $res = 0;
    for my $v (values %$map) {
        if (ref($v) eq 'HASH') {
            $res += active_count($v);
        }
        else {
            $res++ if $v eq '#';
        }
    }
    return $res;
}
