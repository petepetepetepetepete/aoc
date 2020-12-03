#!/usr/bin/env perl

use strict;
use warnings;

use Math::Prime::Util qw/lcm/;

my $infile = shift;

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

my %steps = map { $_ => 0 } qw/x y z/;
for my $axis (qw/x y z/) {
    while (1) {
        last if done(\@moons, $axis);
        apply_gravity(\@moons, $axis);
        apply_velocity(\@moons, $axis);
        $steps{$axis}++;
    }
}

my $steps = lcm(values %steps);
print "$steps\n";

my %state;
sub done {
    my ($moons, $axis) = @_;
    my $s = join(',', map { my $m = $_; map { $m->{$_}{$axis} } qw/pos vel/ } @moons);
    return 1 if defined $state{$axis}{$s};
    $state{$axis}{$s}++;
    return 0;
}

sub apply_gravity {
    my ($moons, $axis) = @_;
    for my $m1 (@$moons) {
        for my $m2 (@{$m1->{other_moons}}) {
            if ($m1->{pos}{$axis} > $m2->{pos}{$axis}) {
                $m1->{vel}{$axis}--;
            }
            elsif ($m1->{pos}{$axis} < $m2->{pos}{$axis}) {
                $m1->{vel}{$axis}++;
            }
        }
    }
}

sub apply_velocity {
    my ($moons, $axis) = @_;
    for my $m (@$moons) {
        $m->{pos}{$axis} += $m->{vel}{$axis};
    }
}

