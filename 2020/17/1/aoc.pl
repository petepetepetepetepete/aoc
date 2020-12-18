#!/usr/bin/env perl

use strict;
use warnings;

use Storable qw/dclone/;
use List::Util qw/min max/;

my %m;

my $min_z = 0;
my $max_z = 0;
my $min_y = 0;
my $max_y = 0;
my $min_x = 0;
my $max_x = 0;
while (my $line = <>) {
    chomp $line;
    my @c = split //, $line;
    $max_x = $#c;
    for my $x (0..$#c) {
        $m{$max_z}{$max_y}{$x} = $c[$x];
    }
    $max_y++;
}
$max_y--;

for my $i (1..6) {
    step(\%m);
}

print active_count(\%m) . "\n";

sub step {
    my $map = shift;

    my $m2 = dclone($map);
    for my $z ($min_z-1..$max_z+1) {
        for my $y ($min_y-1..$max_y+1) {
            for my $x ($min_x-1..$max_x+1) {
                my $c = calc($m2, $x, $y, $z);
                if (defined $c) {
                    $map->{$z}{$y}{$x} = $c;
                    $min_x = min($min_x, $x);
                    $max_x = max($max_x, $x);
                    $min_y = min($min_y, $y);
                    $max_y = max($max_y, $y);
                    $min_z = min($min_z, $z);
                    $max_z = max($max_z, $z);
                }
            }
        }
    }
}

sub calc {
    my ($map, $x, $y, $z) = @_;
    my $active = 0;
    for my $z2 ($z-1..$z+1) {
        next unless exists $map->{$z2};
        for my $y2 ($y-1..$y+1) {
            next unless exists $map->{$z2}{$y2};
            for my $x2 ($x-1..$x+1) {
                next unless exists $map->{$z2}{$y2}{$x2};
                next if $x == $x2 && $y == $y2 && $z == $z2;
                $active++ if $map->{$z2}{$y2}{$x2} eq '#';
            }
        }
    }

    if (($map->{$z}{$y}{$x} // '.') eq '#' && ($active < 2 || $active > 3)) {
        return '.';
    }
    elsif (($map->{$z}{$y}{$x} // '.') eq '.' && $active == 3) {
        return '#';
    }

    return $map->{$z}{$y}{$x};
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

