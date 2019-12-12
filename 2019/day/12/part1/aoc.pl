#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $infile = shift;
my $steps = shift;

my @moons;

my $id = 0;
open my $fh, "<$infile" or die;
while (my $line = <$fh>) {
    chomp $line;
    my ($x, $y, $z) = $line =~ m/<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/;
    die unless defined $x && defined $y && defined $z;

    push @moons, { id => $id++, pos => { x => $x, y => $y, z => $z }, vel => { map { $_ => 0 } qw/x y z/ } };
}
close $fh;

for my $m (@moons) {
    $m->{other_moons} = [ grep { $m->{id} != $_->{id} } @moons ];
}

for my $step (1..$steps) {
    apply_gravity(\@moons);
    apply_velocity(\@moons);
}

my $energy = sum(map { my $m = $_; sum(map { abs($m->{pos}{$_}) } qw/x y z/) * sum(map { abs($m->{vel}{$_}) } qw/x y z/) } @moons);
print "$energy\n";

sub apply_gravity {
    my ($moons) = @_;
    for my $m1 (@$moons) {
        for my $m2 (@{$m1->{other_moons}}) {
            for my $axis (qw/x y z/) {
                if ($m1->{pos}{$axis} > $m2->{pos}{$axis}) {
                    $m1->{vel}{$axis}--;
                }
                elsif ($m1->{pos}{$axis} < $m2->{pos}{$axis}) {
                    $m1->{vel}{$axis}++;
                }
            }
        }
    }
}

sub apply_velocity {
    my ($moons) = @_;
    for my $m (@$moons) {
        for my $axis (qw/x y z/) {
            $m->{pos}{$axis} += $m->{vel}{$axis};
        }
    }
}
