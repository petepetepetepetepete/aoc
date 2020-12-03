#!/usr/bin/env perl

use strict;
use warnings;

package IntCode;

my %opcodes = (
    1 => sub {
        my ($self) = @_;
        $self->set_value(3, $self->get_value(1) + $self->get_value(2));
        $self->{ip} += 4;
    },
    2 => sub {
        my ($self) = @_;
        $self->set_value(3, $self->get_value(1) * $self->get_value(2));
        $self->{ip} += 4;
    },
    3 => sub {
        my ($self) = @_;
        my $input;
        if (ref($self->{read_cb}) eq 'CODE') {
            $input = $self->{read_cb}->($self, $self->{read_cb_data});
        }
        else {
            $input = <STDIN>;
            chomp $input;
        }
        $self->set_value(1, $input);
        $self->{ip} += 2;
    },
    4 => sub {
        my ($self) = @_;
        my $value = $self->get_value(1);
        if (ref($self->{write_cb}) eq 'CODE') {
            $self->{write_cb}->($self, $value, $self->{write_cb_data});
        }
        else {
            print "$value\n";
        }
        $self->{ip} += 2;
    },
    5 => sub {
        my ($self) = @_;
        if ($self->get_value(1)) {
            $self->{ip} = $self->get_value(2);
        }
        else {
            $self->{ip} += 3;
        }
    },
    6 => sub {
        my ($self) = @_;
        if ($self->get_value(1) == 0) {
            $self->{ip} = $self->get_value(2);
        }
        else {
            $self->{ip} += 3;
        }
    },
    7 => sub {
        my ($self) = @_;
        $self->set_value(3, $self->get_value(1) < $self->get_value(2) ? 1 : 0);
        $self->{ip} += 4;
    },
    8 => sub {
        my ($self) = @_;
        $self->set_value(3, $self->get_value(1) == $self->get_value(2) ? 1 : 0);
        $self->{ip} += 4;
    },
    9 => sub {
        my ($self) = @_;
        $self->{relative_base} += $self->get_value(1);
        $self->{ip} += 2;
    },
    99 => sub {
        my ($self) = @_;
        if (ref($self->{halt_cb}) eq 'CODE') {
            $self->{halt_cb}->($self, $self->{halt_cb_data});
        }
        return -1;
    }
);

sub new {
    my ($class, $prog_file) = @_;
    die unless $class && $prog_file;

    open my $fh, "<$prog_file" or die "Failed to open $prog_file for read: $!";
    my $prog = <$fh>;
    chomp $prog;
    close $fh;

    my $i = 0;
    return bless {
        prog => { map { $i++ => $_ } split /,/, $prog },
        ip => 0,
        relative_base => 0,
    }, $class;
}

sub set_read_cb {
    my ($self, $cb, $data) = @_;

    if ($cb) {
        $self->{read_cb} = $cb;
        $self->{read_cb_data} = $data if defined $data;
    }
    else {
        delete $self->{read_cb};
    }
}

sub set_write_cb {
    my ($self, $cb, $data) = @_;

    if ($cb) {
        $self->{write_cb} = $cb;
        $self->{write_cb_data} = $data if defined $data;
    }
    else {
        delete $self->{write_cb};
    }
}

sub set_halt_cb {
    my ($self, $cb, $data) = @_;

    if ($cb) {
        $self->{halt_cb} = $cb;
        $self->{halt_cb_data} = $data if defined $data;
    }
    else {
        delete $self->{halt_cb};
    }
}

sub set_pre_run_cb {
    my ($self, $cb, $data) = @_;

    if ($cb) {
        $self->{pre_run_cb} = $cb;
        $self->{pre_run_cb_data} = $data if defined $data;
    }
    else {
        delete $self->{pre_run_cb};
    }
}

sub set_value {
    my ($self, $offset, $value) = @_;

    my $ip = $self->{ip};
    my $opcode = $self->{prog}->{$ip};
    my $type = ($opcode / (10 ** ($offset + 1))) % 10;
    if ($type == 0) {
        $self->{prog}->{$self->{prog}->{$ip+$offset}} = $value;
    }
    elsif ($type == 1) {
        $self->{prog}->{$ip+$offset} = $value;
    }
    elsif ($type == 2) {
        $self->{prog}->{$self->{relative_base} + $self->{prog}->{$ip+$offset}} = $value;
    }
    else {
        die "Invalid parameter type: $type";
    }
}

sub get_value {
    my ($self, $offset) = @_;
    my $ip = $self->{ip};
    my $opcode = $self->{prog}->{$ip};
    my $type = ($opcode / (10 ** ($offset + 1))) % 10;
    if ($type == 0) {
        return $self->{prog}->{$self->{prog}->{$ip+$offset}} // 0;
    }
    elsif ($type == 1) {
        return $self->{prog}->{$ip+$offset} // 0;
    }
    elsif ($type == 2) {
        return $self->{prog}->{$self->{relative_base} + $self->{prog}->{$ip+$offset}} // 0;
    }
    else {
        die "Invalid parameter type: $type";
    }
}

sub run {
    my $self = shift;

    if (ref($self->{pre_run_cb}) eq 'CODE') {
        $self->{pre_run_cb}->($self, $self->{pre_run_cb_data});
    }

    while (1) {
        my $res = $self->opcode();
        last if $res == -1;
    }
}

sub opcode {
    my ($self) = @_;

    my $ip = $self->{ip};
    my $opcode = $self->{prog}->{$ip} % 100;
    if (ref $opcodes{$opcode} eq 'CODE') {
        return $opcodes{$opcode}->($self);
    }
    else {
        die "Unknown opcode: $opcode ($self->{prog}->{$ip}) at offset=$ip";
    }
}

1;

package main;

use Graph;
use List::Util qw/min max/;
use Term::Cap;
use Time::HiRes;

my $prog_file = shift;

my $min_x = 999_999;
my $max_x = -999_999;
my $min_y = 999_999;
my $max_y = -999_999;
my $x = 0;
my $y = 0;

my $start = [0,0];
my $target;
my %map = ( 0 => { 0 => 'X' } );

my $write_count = 0;

my $ic = IntCode->new($prog_file);

my @q;
my $dir;

system('clear');
my $terminal = Tgetent Term::Cap;
$| = 1;

$ic->set_write_cb(sub {
        my ($self, $value) = @_;

        $min_x = min($x, $min_x);
        $max_x = max($x, $max_x);
        $min_y = min($y, $min_y);
        $max_y = max($y, $max_y);

        print $terminal->Tgoto('cm', $x + 21, $y + 21);
        if ($value == 0) {
            print '#';
            $map{$y}{$x} = '#';

            my $dir = pop @q;
            $y-- if $dir == 1;
            $y++ if $dir == 2;
            $x-- if $dir == 3;
            $x++ if $dir == 4;
        }
        elsif ($value == 1) {
            print '.';
            $map{$y}{$x} //= '.';
        }
        elsif ($value == 2) {
            print '*';
            $map{$y}{$x} //= '*';
            $target //= [$x,$y];
        }
        else {
            die "Unexpected value: $value";
        }

        print $terminal->Tgoto('cm', 0, 50);
        Time::HiRes::sleep 1/240;
    });

$ic->set_read_cb(sub {
        my ($self) = @_;
        
        if (!defined $map{$y-1}{$x}) {
            $y--;
            push @q, 2;
            return 1;
        }
        if (!defined $map{$y+1}{$x}) {
            $y++;
            push @q, 1;
            return 2;
        }
        if (!defined $map{$y}{$x-1}) {
            $x--;
            push @q, 4;
            return 3;
        }
        if (!defined $map{$y}{$x+1}) {
            $x++;
            push @q, 3;
            return 4;
        }

        return 0 unless @q;
        my $dir = pop @q;
        $y-- if $dir == 1;
        $y++ if $dir == 2;
        $x-- if $dir == 3;
        $x++ if $dir == 4;

        return $dir;
    });

$ic->set_halt_cb(sub {
        my $g = Graph->new(directed => 0);
        for my $y ($min_y..$max_y) {
            for my $x ($min_x..$max_x) {
                next if ($map{$y}{$x} // '') eq '#';
                for my $i ($y-1, $y+1) {
                    $g->add_edge("$x,$y", "$x,$i") if defined $map{$i}{$x} && $map{$i}{$x} ne '#';
                }
                for my $i ($x-1, $x+1) {
                    $g->add_edge("$x,$y", "$i,$y") if defined $map{$y}{$i} && $map{$y}{$i} ne '#';
                }
            }
        }

        my @path = $g->SP_Dijkstra(join(',', @$start), join(',', @$target));
        printf "%d\n", scalar(@path) - 1;

    });

$ic->run();
