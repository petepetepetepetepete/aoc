#!/usr/bin/env perl

use strict;
use warnings;

use Math::Polygon;

my @m = (['#']);
my @plan = map { chomp; [ split / /, $_ ] } <>;

my ($x,$y) = (0,0);

my @points = [$x,$y];
for my $i (0..$#plan) {
    my $step = $plan[$i];
    my ($dir, $len, $rgb) = @$step;

    my $s = join('', map { my $j = ($i+$_) % scalar(@plan); $plan[$j][0] } (-1..1));
    if ($s =~ m/^(?:RDL|DLU|LUR|URD)$/) {
        $len++;
    }
    elsif ($s =~ m/^(?:RUL|DRU|LDR|ULD)$/) {
        $len--;
    }

    if ($dir eq 'R') {
        $x += $len;
    }
    elsif ($dir eq 'L') {
        $x -= $len;
    }
    elsif ($dir eq 'U') {
        $y += $len;
    }
    elsif ($dir eq 'D') {
        $y -= $len;
    }
    else {
        die "Unexpected dir: $dir";
    }
    push @points, [$x,$y];
}

my $poly = Math::Polygon->new(@points);
print $poly->area . "\n";
