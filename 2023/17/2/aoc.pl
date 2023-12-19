#!/usr/bin/env perl

use strict;
use warnings;

package Node;

use overload
    '==' => \&equals,
    '""' => \&to_string;

sub new {
    my ($class, $x, $y, $hl) = @_;
    return bless { x => $x, y => $y, heatloss => $hl, neighbours => {} }, $class;
} 

sub x { $_[0]->{x} }
sub y { $_[0]->{y} }
sub heatloss { $_[0]->{heatloss} }
sub neighbours { $_[0]->{neighbours} }

sub add_neighbour {
    my ($self, $dir, $node) = @_;
    $self->{neighbours}{$dir} = $node;
}

sub equals {
    my ($a, $b) = @_;
    return $a->x == $b->x && $a->y == $b->y;
}

sub to_string {
    my ($self) = @_;
    return sprintf("%d,%d", $self->x, $self->y);
}

sub distance {
    my ($a, $b) = @_;
    return abs($a->x - $b->x) + abs($a->y - $b->y);
}

1;

use List::Util qw/min/;
use Tie::Array::Sorted;

my %opp = (
    '>' => '<',
    '<' => '>',
    '^' => 'v',
    'v' => '^',
);
my %dir = (
    '>' => [1,0],
    '<' => [-1,0],
    '^' => [0,-1],
    'v' => [0,1],
);
my %lr = (
    '>' => [qw/^ v/],
    '<' => [qw/^ v/],
    '^' => [qw/< >/],
    'v' => [qw/< >/],
);

my @m = map { chomp; [ split //, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};

my @node_map = map { my $y=$_; [ map { Node->new($_, $y, $m[$y][$_]) } (0..$max_x) ] } (0..$max_y);
for my $y (0..$max_y) {
    for my $x (0..$max_x) {
        my @cur = ($x,$y);
        while (my ($dir, $pt) = each %dir) {
            my ($nx,$ny) = map { $cur[$_] + $pt->[$_] } (0..$#cur);
            next if $nx < 0 or $nx > $max_x or $ny < 0 or $ny > $max_y;

            $node_map[$y][$x]->add_neighbour($dir, $node_map[$ny][$nx]);
        }
    }
}

my $start = $node_map[0][0];
my $target = $node_map[$max_y][$max_x];

# x,y,dir,dircount
my %seen;

my $min_cost = ~0;

# [ node, cost, directions ]
my @q;
tie @q, 'Tie::Array::Sorted', sub { $_[0]->[1] <=> $_[1]->[1] };
push @q, [ $start, 0, [] ];
while (@q) {
    my ($node, $cost, $dirs) = @{shift @q};

    # count how many times we've move in the same direction
    my $dir_count = 0;
    my $i = -1;
    my $dir = $dirs->[$i] // '';
    $dir_count++ while defined $dirs->[$i] && $dir eq $dirs->[$i--];

    # we've reached our goal
    if ($node == $target) {
        if ($dir_count >= 4) {
            $min_cost = min($cost, $min_cost);
            warn "$cost $min_cost / " . scalar(@q);
        }
        next;
    }

    my $k = join(',', $node->x, $node->y, $dir, $dir_count);

    # skip if we've come to this node the same way before
    next if defined $seen{$k} && $seen{$k} <= $cost;

    $seen{$k} = $cost;

    my @dirs;

    if ($dir eq '') {
        # initial state
        @dirs = keys %dir;
    }
    elsif ($dir_count < 4) {
        # we must keep moving in the same direction
        @dirs = $dir;
    }
    else {
        if ($dir_count < 10) {
            # we may continue moving in the same direction
            push @dirs, $dir;
        }
        # we can turn left or right
        push @dirs, @{$lr{$dir}};
    }

    my $neighbours = $node->neighbours;
    for my $ndir (@dirs) {
        my $neighbour = $neighbours->{$ndir};
        next unless $neighbour;
        push @q, [ $neighbour, $cost + $neighbour->heatloss, [ @$dirs, $ndir ] ];
    }
}

print $min_cost . "\n";
