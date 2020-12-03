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

my $prog_file = shift;

my %map = ( 0 => { 0 => 'X' } );

my $ic = IntCode->new($prog_file);

my $map = '';
$ic->set_write_cb(sub {
        my ($self, $value) = @_;
        $map .= chr($value);
    });

$ic->set_halt_cb(sub {
        my %map;
        my $y = 0;
        my $max_x;
        my $max_y;
        for my $line (split /\n/, $map) {
            my @line = split //, $line;
            $max_x //= $#line;
            $map{$y} = { map { $_ => $line[$_] } (0..$#line) };
            $y++;
        }
        $max_y = $y-1;

        my $sum = 0;
        for my $y (0..$max_y) {
            for my $x (0..$max_x) {
                next unless $map{$y}{$x} eq '#';
                my $match = 0;
                for my $i ($x-1, $x+1) {
                    next unless defined $map{$y}{$i} && $map{$y}{$i} eq '#';
                    $match++;
                }
                for my $i ($y-1, $y+1) {
                    next unless defined $map{$i}{$x} && $map{$i}{$x} eq '#';
                    $match++;
                }

                next unless $match == 4;

                $map{$y}{$x} = 'O';
            }
        }

        my @input;
        push @input, map { ord($_) } split //, "B,B,C,A,A,B,C,A,B,C\n";
        push @input, map { ord($_) } split //, "L,10,R,8,R,12\n";
        push @input, map { ord($_) } split //, "L,12,L,12,R,12\n";
        push @input, map { ord($_) } split //, "L,8,L,8,R,12,L,8,L,8\n";
        push @input, map { ord($_) } split //, "n\n";
        my $ic2 = IntCode->new($prog_file);
        $ic2->set_pre_run_cb(sub {
                my ($self) = @_;
                $self->{prog}{0} = 2;
            });
        $ic2->set_write_cb(sub {
                my ($self, $value) = @_;
                if ($value < 256) {
                    print chr($value);
                }
                else {
                    print "$value\n";
                }
            });
        $ic2->set_read_cb(sub {
                my ($self) = @_;
                my $input = shift @input;
                return $input;
            });
        $ic2->set_halt_cb(sub {
                my ($self) = @_;
            });
        $ic2->run();
    });

$ic->run();
