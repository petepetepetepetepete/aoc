#!/usr/bin/env perl

use strict;

use Algorithm::Combinatorics qw/combinations/;
use List::MoreUtils qw/minmax/;
use List::Util qw/all sum/;

my $mult = shift;
my @g = map { chomp; [ split //, $_ ] } <>;

my $max_y = $#g;
my $max_x = $#{$g[0]};

my %mult;
$mult{0} = {
    map { my $x=$_; $x => (all { $g[$_][$x] eq '.' } (0..$max_y)) ? $mult : 1 } (0..$max_x)
};
$mult{1} = {
    map { my $y=$_; $y => (all { $g[$y][$_] eq '.' } (0..$max_x)) ? $mult : 1 } (0..$max_y)
};

my @pts = grep { my ($x,$y)=@$_; $g[$y][$x] eq '#' } map { my $y=$_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);

my $result = 0;
my $iter = combinations(\@pts, 2);
while (my $c = $iter->next) {
    my ($a, $b) = @$c;
    $result += sum(
        map {
            my $i = $_;
            my ($m, $n) = minmax($a->[$_], $b->[$_]);
            map { $mult{$i}{$_} } ($m+1..$n)
        } (0..1)
    );
}

print $result . "\n";

