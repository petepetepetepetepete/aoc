#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/first/;

my $res = 0;
while (my $line = <>) {
    chomp $line;
    $res += output_value($line);
}

print $res . "\n";

sub output_value {
    my $line = shift;

    my @a = split / \| /, $line;
    my @signal = split / /, $a[0];
    my @out = split / /, $a[1];
    my @digits = (@signal, @out);

    my $one = first { length($_) == 2 } @digits;
    my $seven = first { length($_) == 3 } @digits;
    my $four = first { length($_) == 4 } @digits;
    my $eight = first { length($_) == 7 } @digits;

    my $res = '';
    for my $out (@out) {
        if (length($out) == 2) { $res .= 1; }
        elsif (length($out) == 3) { $res .= 7; }
        elsif (length($out) == 4) { $res .= 4; }
        elsif (length($out) == 7) { $res .= 8; }
        elsif (length($out) == 5) { # 2, 3, 5
            if (segment_overlap($out, $one) == 2) { $res .= 3; }
            elsif (segment_overlap($out, $four) == 2) { $res .= 2; }
            elsif (segment_overlap($out, $four) == 3) { $res .= 5; }
            else { die $out; }
        }
        elsif (length($out) == 6) { # 0, 6, 9
            if (segment_overlap($out, $one) == 1) { $res .= 6; }
            elsif (segment_overlap($out, $four) == 4) { $res .= 9; }
            elsif (segment_overlap($out, $four) == 3) { $res .= 0; }
            else { die $out; }
        }
        else {
            die "Unexpected length: $out";
        }
    }
    
    return int($res);
}

sub segment_overlap {
    my ($a, $b) = @_;
    return scalar(grep { $a =~ m/$_/; } split //, $b);
}
