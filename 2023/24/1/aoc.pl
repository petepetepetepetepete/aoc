#!/usr/bin/env perl

use strict;
use warnings;

my $min = $ENV{TEST} ? 7 : 200000000000000;
my $max = $ENV{TEST} ? 27 : 400000000000000;

my @hs;
while (my $line = <>) {
    chomp $line;
    my ($position, $velocity) = split / *\@ */, $line;
    my ($x,$y,$z) = split /, */, $position;
    my ($dx,$dy,$dz) = split /, */, $velocity;
    
    my $x1 = $x + $dx;
    my $y1 = $y + $dy;

    my $m = ($y1 - $y) / ($x1 - $x);
    my $b = $y - $m * $x;

    push @hs, { 
        line => $line,
        future => sub {
            my ($x2, $y2) = @_;

            return 0 if $dx > 0 and $x2 < $x;
            return 0 if $dx < 0 and $x2 > $x;
            return 0 if $dy > 0 and $y2 < $y;
            return 0 if $dy < 0 and $y2 > $y;

            return 1;
        },
        m => $m,
        b => $b
    };
}

# y = m1 * x + b1
# y = m2 * x + b2
# 0 = (m1-m2) * x + (b1-b2)
# -(b1-b2) = (m1-m2) * x
# (b2-b1)/(m1-m2) = x
my $result = 0;
for my $i (0..$#hs-1) {
    my $m1 = $hs[$i]{m};
    my $b1 = $hs[$i]{b};

    for my $j ($i+1..$#hs) {
        my $m2 = $hs[$j]{m};
        my $b2 = $hs[$j]{b};

        #warn "Hailstone A: $hs[$i]{line}\n";
        #warn "Hailstone B: $hs[$j]{line}\n";

        if ($m1 == $m2) {
            #warn "Hailstones' paths are parallel; they never intersect.\n\n";
            next;
        }

        my $x = ($b2-$b1)/($m1-$m2);
        my $y = $m1 * $x + $b1;

        if ($x < $min or $x > $max or $y < $min or $y > $max) {
            #warn "Hailstones' paths will cross outside the test area at (x=$x, y=$y)\n\n";
            next;
        }

        if (!$hs[$i]{future}->($x,$y) && !$hs[$j]{future}->($x,$y)) {
            #warn "Hailstones' paths crossed in the past for both hailstones.\n\n";
            next;
        }

        if (!$hs[$i]{future}->($x,$y)) {
            #warn "Hailstones' paths crossed in the past for hailstone A.\n\n";
            next;
        }

        if (!$hs[$j]{future}->($x,$y)) {
            #warn "Hailstones' paths crossed in the past for hailstone B.\n\n";
            next;
        }

        $result++;
        #warn "Hailstones' paths will cross inside the test area (at x=$x, y=$y).\n\n";
    }
}

print $result . "\n";
