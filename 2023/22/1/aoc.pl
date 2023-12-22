#!/usr/bin/env perl

use strict;
use warnings;

package Brick;

use constant {
    MIN => 0,
    MAX => 1,
    X => 0,
    Y => 1,
    Z => 2, 
};

my $label = 'A';

sub new {
    my ($class, $s) = @_;
    my (@s) = split /~/, $s;

    my @pts = map { [ split /,/, $_ ] } @s;

    return bless {
        x1 => $pts[0][X],
        x2 => $pts[1][X],
        y1 => $pts[0][Y],
        y2 => $pts[1][Y],
        z1 => $pts[0][Z],
        z2 => $pts[1][Z],
        label => $label++
    }, $class;
}

sub top { $_[0]->{z2} }
sub bottom { $_[0]->{z1} }

# is $self supporting $other
sub supporting {
    my ($self, $other) = @_;

    return 0 if $other->{z1} - $self->{z2} != 1;
    return 0 if $other->{x1} > $self->{x2} or $self->{x1} > $other->{x2};
    return 0 if $other->{y1} > $self->{y2} or $self->{y1} > $other->{y2};

    return 1;
}

# is $self is suported by $other
sub supported_by {
    my ($self, $other) = @_;

    return 0 if $other->{z2} - $self->{z1} != 1;
    return 0 if $other->{x1} > $self->{x2} or $self->{x1} > $other->{x2};
    return 0 if $other->{y1} > $self->{y2} or $self->{y1} > $other->{y2};

    return 1;
}

sub step {
    my ($self) = @_;
    $self->{$_}-- foreach qw/z1 z2/;
    $self;
}

sub to_string {
    my ($self) = @_;
    return sprintf '%s: %d,%d,%d~%d,%d,%d', $self->{label}, map { $self->{$_} } qw/x1 y1 z1 x2 y2 z2/;
}

1;

use List::Util qw/all min max/;
use Tie::Array::Sorted;

my @bricks;
my @settled;
tie @bricks, 'Tie::Array::Sorted', sub { $_[0]->bottom() <=> $_[1]->bottom() };
tie @settled, 'Tie::Array::Sorted', sub { $_[0]->top() <=> $_[1]->top() };

while (my $line = <>) {
    chomp $line;
    push @bricks, Brick->new($line);
}

#print_bricks(@bricks);

my %supporting;
my %supported_by;
while (@bricks) {
    warn scalar(@settled) . ' / ' . scalar(@bricks) . "\n";
    my $b = shift @bricks;

    my $supporting;
    while (!defined ($supporting = settled($b))) {
        $b->step();
    }
    $supported_by{$b->{label}} = [ map { $_->{label} } @$supporting ];

    push @settled, $b;
}
#print_bricks(@settled);

# reverse mapping
while (my ($k,$v) = each %supported_by) {
    push @{$supporting{$_}}, $k foreach @$v;
}

my $result = 0;
for my $b (@settled) {
    # not supporting any bricks
    if (!exists $supporting{$b->{label}}) {
        $result++;
    }
    else {
        # if all of the bricks that we're supporting have more than one supported_by, then we can disintegrate
        $result++ if all { @{$supported_by{$_}} > 1 } @{$supporting{$b->{label}}};
    }
}

print $result . "\n";
exit 0;

sub settled {
    my ($brick) = @_;

    return [] if $brick->bottom() == 1;

    my @supporting;
    for my $b (grep { $_->top() + 1 == $brick->bottom() } @settled) {
        push @supporting, $b if $b->supporting($brick);
    }

    return unless @supporting;

    return [@supporting];
}

sub print_bricks {
    my @b = @_;

    my $max_x = max(map { $_->{x2} } @b);
    my $max_y = max(map { $_->{y2} } @b);
    my $max_z = max(map { $_->{z2} } @b);

    my %zx; # z,x
    my %zy; # z,y
    my %zyx; # z,y,x
    for my $b (@b) {
        for my $z ($b->{z1}..$b->{z2}) {
            for my $x ($b->{x1}..$b->{x2}) {
                $zx{$z}{$x} = exists $zx{$z}{$x} ? '???' : $b->{label};
            }
            for my $y ($b->{y1}..$b->{y2}) {
                $zy{$z}{$y} = exists $zy{$z}{$y} ? '???' : $b->{label};
            }
            for my $y ($b->{y1}..$b->{y2}) {
                for my $x ($b->{x1}..$b->{x2}) {
                    $zyx{$z}{$y}{$x} = $b->{label};
                } 
            }
        }

    }

    warn "x\n";
    warn join('   ', (0..$max_x)) . "\n";
    for my $z (reverse 1..$max_z) {
        my $s = '';
        for my $x (0..$max_x) {
            $s .= $zx{$z}{$x} // '...';
            $s .= ' ';
        }
        warn "$s $z\n";
    }
    warn '----' x ($max_x+1) . " 0\n\n";

    warn "y\n";
    warn join('   ', (0..$max_y)) . "\n";
    for my $z (reverse 1..$max_z) {
        my $s = '';
        for my $y (0..$max_y) {
            $s .= $zy{$z}{$y} // '...';
            $s .= ' ';
        }
        warn "$s $z\n";
    }
    warn '----' x ($max_y+1) . " 0\n\n";

    #    warn "z\n";
    #    for my $z (1..$max_z) {
    #        warn "z=$z\n";
    #        warn join('', (0..$max_x)) . "\n";
    #        for my $y (0..$max_y) {
    #            my $s = '';
    #            for my $x (0..$max_x) {
    #                $s .= $zyx{$z}{$y}{$x} // '.';
    #            }
    #            warn "$s $y\n";
    #        }
    #        warn "\n\n";
    #    }
}
