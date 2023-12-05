#!/usr/bin/env perl

use strict;
use warnings;

my @map = map { chomp; [ split //, $_ ] } <>;

my $result = 0;
for my $y (0..$#map) {
    my $num = '';
    my $valid = 0;
    my $max_x = $#{$map[$y]};
    for my $x (0..$max_x) {
        if ($map[$y][$x] eq '*') {
            my (@parts) = find_parts(\@map, $x, $y, $max_x, $#map);
            $result += $parts[0] * $parts[1] if @parts == 2;
        }
    }
}

sub find_parts {
    my ($m, $x, $y, $max_x, $max_y) = @_;

    my %part_offsets;

    for my $x1 (-1..1) {
        next if $x + $x1 < 0;
        next if $x + $x1 > $max_x;
        for my $y1 (-1..1) {
            next if $x1 == 0 and $y1 == 0;
            next if $y + $y1 < 0;
            next if $y + $y1 > $max_y;

            if ($m->[$y+$y1][$x+$x1] =~ m/[0-9]/) {
                my $x2 = $x+$x1;
                my $y2 = $y+$y1;
                $x2-- while $x2 >= 0 and $m->[$y2][$x2-1] =~ m/[0-9]/;
                $part_offsets{"$x2,$y2"}++;
            }
        }
    }

    return unless scalar(keys %part_offsets) == 2;

    my @result;
    for my $offset (keys %part_offsets) {
        my $num = '';
        my ($x1, $y1) = split /,/, $offset;
        while ($x1 <= $max_x && $m->[$y1][$x1] =~ m/[0-9]/) {
            $num .= $m->[$y1][$x1];
            $x1++;
        }

        push @result, $num;
    }

    return @result;
}

print $result . "\n";
