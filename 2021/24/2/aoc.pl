#!/usr/bin/env perl

use strict;
use warnings;

package ALU;

sub new {
    my ($class, @instr) = @_;

    my $self = {
        w => 0,
        x => 0,
        y => 0,
        z => 0,
        inp => sub {
            my ($self, $a) = @_;
            $self->{$a} = shift @{$self->{input}};
        },
        add => sub {
            my ($self, $a, $b) = @_;
            $self->{$a} += ($self->{$b} // $b);
        },
        mul => sub {
            my ($self, $a, $b) = @_;
            $self->{$a} *= ($self->{$b} // $b);
        },
        div => sub {
            my ($self, $a, $b) = @_;
            die "Unexpected div $a $b" if ($self->{$b} // $b) == 0;
            $self->{$a} /= ($self->{$b} // $b);
            $self->{$a} = int($self->{$a});
        },
        mod => sub {
            my ($self, $a, $b) = @_;
            die "Unexpected mod $a $b" if $self->{$a} < 0 || ($self->{$b} // $b) <= 0;
            $self->{$a} %= ($self->{$b} // $b);
        },
        eql => sub {
            my ($self, $a, $b) = @_;
            $self->{$a} = int($self->{$a} == ($self->{$b} // $b));
        },
    };

    for my $line (@instr) {
        chomp $line;
        my ($i, @args) = split / /, $line;
        my $f = $self->{$i};
        die unless ref($self->{$i}) eq 'CODE';
        push @{$self->{instr}}, { f => $f, fname => $i, args => [@args] };
    }

    return bless $self, $class;
}

sub run {
    my ($self, $input) = @_;
    $self->{input} = [ split //, $input ];
    $self->{$_} = 0 foreach qw/w x y z/;

    for my $i (@{$self->{instr}}) {
        $i->{f}->($self, @{$i->{args}});
    }

    return $self->{z};
}


1;

# Input algorithm maps to the following:
#
# push @a, (w0 + 6)	# [w0+6]
# push @a, (w1 + 12)	# [w0+6, w1+12]
# push @a, (w2 + 8)	# [w0+6, w1+12, w2+8]
# 
# if w3 != pop @a - 11	# [w0+6, w1+12] w3 = w2-3
#   push @a, (w3 + 7)
# 
# push @a, (w4 + 7)	# [w0+6, w1+12, w4+7]
# push @a, (w5 + 12)	# [w0+6, w1+12, w4+7, w5+12]
# push @a, (w6 + 2)	# [w0+6, w1+12, w4+7, w5+12, w6+2]
# 
# if w7 != pop @a - 7	# [w0+6, w1+12, w4+7, w5+12] w7 = w6-5
#   push @a, (w7 + 15)
# 
# push @a, (w8 + 4)	# [w0+6, w1+12, w4+7, w5+12, w8+4]
# 
# if w9 != pop @a - 6	# [w0+6, w1+12, w4+7, w5+12] w9 = w8-2
#   push @a, (w9 + 5)
# 
# if w10 != pop @a - 10	# [w0+6, w1+12, w4+7] w10 = w5+2
#   push @a, (w10 + 12)
# 
# if w11 != pop @a - 15	# [w0+6, w1+12] w11 = w4-8
#   push @a, (w11 + 11)
# 
# if w12 != pop @a - 9	# [w0+6] w12 = w1+3
#   push @a, (w12 + 13)
# 
# if w13 != pop @a	#[] w13 = w0+6
#   push @a, (w13 + 7)

my %map = (
    3 => [2, -3],
    7 => [6, -5],
    9 => [8, -2],
    10 => [5, 2],
    11 => [4, -8],
    12 => [1, 3],
    13 => [0, 6]
);
my @res;
while (my ($k, $v) = each %map) {
    if ($v->[1] < 0) {
        $res[$k] = 1;
        $res[$v->[0]] = 1 - $v->[1];
    }
    else {
        $res[$v->[0]] = 1;
        $res[$k] = 1 + $v->[1];
    }
}

my $alu = ALU->new(<>);
my $res = join '', @res;
print "$res\n" if $alu->run($res) == 0;
