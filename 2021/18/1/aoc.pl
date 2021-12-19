#!/usr/bin/env perl

use strict;
use warnings;

package Pair::Value;

sub new {
    my ($class, $v, $pair) = @_;
    return bless { pair => $pair, value => $v }, $class;
}

sub get_value {
    my $self = shift;
    return $self->{value};
}

sub magnitude {
    my $self = shift;
    return $self->get_value();
}

sub add_to_value {
    my ($self, $v) = @_;
    $self->{value} += $v;
}

sub get_pair {
    my $self = shift;
    return $self->{pair};
}

sub split {
    my $self = shift;
    my $v = $self->{value};
    return if $v < 10;
    return [ int($v/2), int($v/2+.9) ];
}

sub to_string {
    my $self = shift;
    return $self->get_value();
}

1;

package Pair;

use List::Util qw/first/;

sub new {
    my ($class, $a, $idx, $parent, $depth) = @_;
    $depth //= 0;

    my $self = { depth => $depth, idx => $idx, parent => $parent };
    for my $i (0..1) {
        if (ref($a->[$i])) {
            $self->{$i} = Pair->new($a->[$i], $i, $self, $depth + 1);
        }
        else {
            $self->{$i} = Pair::Value->new($a->[$i], $self, $depth);
        }
    }

    return bless $self, $class;
}

sub set_at_idx {
    my ($self, $val, $idx) = @_;
    $self->{$idx} = $val;
}

sub get_depth {
    my $self = shift;
    return $self->{depth};
}

sub get_index {
    my $self = shift;
    return $self->{idx};
}

sub get_parent {
    my $self = shift;
    return $self->{parent};
}

sub pv_list {
    my $self = shift;
    my @list;
    for my $k (qw/0 1/) {
        if (ref($self->{$k}) eq 'Pair') {
            push @list, $self->{$k}->pv_list();
        }
        else {
            push @list, $self->{$k};
        }
    }
    return @list;
}

sub pv_count {
    my $self = shift;
    my $count = 0;
    for my $k (qw/0 1/) {
        if (ref($self->{$k}) eq 'Pair') {
            $count += $self->{$k}->pv_count();
        }
        else {
            $count++;
        }
    }
    return $count;
}

sub to_string {
    my $self = shift;
    return '[' . join(',', map { $self->{$_}->to_string() } (0..1)) . ']';
}

sub reduce {
    my $self = shift;

    while (1) {
        while (1) {
            last unless $self->explode();
        }
        last unless $self->split();
    }
}

sub explode {
    my $self = shift;
    my @list = $self->pv_list();
    my $pvi = first { $list[$_]->get_pair()->get_depth() >= 4 && $list[$_]->get_pair() == $list[$_+1]->get_pair() } (0..$#list-1);
    return unless defined $pvi;
    if ($pvi > 0) {
        $list[$pvi-1]->add_to_value($list[$pvi]->get_value());
    }
    if ($pvi < $#list-1) {
        $list[$pvi+2]->add_to_value($list[$pvi+1]->get_value());
    }
    my $p = $list[$pvi]->get_pair();
    my $pp = $p->get_parent();
    die unless $pp;
    $pp->set_at_idx(Pair::Value->new(0, $pp, $pp->get_depth()), $p->get_index());

    return 1;
}

sub split {
    my $self = shift;
    for my $i (0..1) {
        my $c = $self->{$i};
        if (ref($c) eq 'Pair') {
            return 1 if $c->split();
        }
        elsif (ref($c) eq 'Pair::Value') {
            my $s = $c->split();
            if ($s) {
                my $pair = Pair->new($s, $i, $self, $self->get_depth() + 1);
                $self->set_at_idx($pair, $i);
                return 1;
            }
        }
    }
    return;
}

sub magnitude {
    my $self = shift;
    
    return 3 * ($self->{0}->magnitude()) + 2 * ($self->{1}->magnitude());
}

sub combine {
    my ($p1, $p2) = @_;
    return $p2 if !defined $p1 && defined $p2;
    return Pair->new(eval('['.$p1->to_string().','.$p2->to_string().']'));
}

1;

my $p;
while (my $line = <>) {
    chomp $line;
    my $x = eval $line;
    my $p2 = Pair->new($x);
    $p2->reduce();
    $p = Pair::combine($p, $p2);
    $p->reduce();
}

print $p->magnitude() . "\n";
