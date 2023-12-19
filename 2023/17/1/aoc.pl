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

# [ node, cost, last 3 dir ]
my @q = [ $start, 0, [] ];
while (@q) {
    my ($node, $cost, $dirs) = @{shift @q};
    my @dirs = @$dirs;

    # we've reached our goal
    if ($node == $target) {
        print $cost . "\n";
        last;
    }

    # count how many times we've move in the same direction
    my $dir_count = 0;
    my $i = -1;
    my $dir = $dirs->[$i] // '';
    $dir_count++ while defined $dirs->[$i] && $dir eq $dirs->[$i--];

    my $k = join(',', $node->x, $node->y, $dir, $dir_count);

    # skip if we've come to this node the same way before
    next if $seen{$k};

    $seen{$k}++;

    while (my ($ndir, $neighbour) = each %{$node->neighbours()}) {
        # skip if this next step would cause us to go too far in the same direction
        next if $dir eq $ndir && $dir_count == 3;

        # skip if this next step would cause us to backtrack
        next if $opp{$ndir} eq $dir;

        push @q, [ $neighbour, $cost + $neighbour->heatloss, [ @$dirs, $ndir ] ];
    }

    # sort by cost
    @q = sort { $a->[1] <=> $b->[1] } @q;
}
