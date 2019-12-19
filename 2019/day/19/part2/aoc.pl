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
    my %prog = map { $i++ => $_ } split /,/, $prog;
    return bless {
        prog => { %prog },
        orig_prog => { %prog },
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

sub reset {
    my ($self) = @_;
    $self->{prog} = { %{$self->{orig_prog}} };
    $self->{ip} = 0;
    $self->{relative_base} = 0;
}

1;

package main;

my $prog_file = shift;

my $ic = IntCode->new($prog_file);

my @input = ([4,6]);
my %map;
my $done = 0;
my @moves;
my $start_x = 0;
my $max_x = 0;
my $max_y = 0;
my $square_size = 1;
my $final_result;

my $state = 0;

$ic->set_write_cb(sub {
        my ($self, $value) = @_;
        my $y = pop @moves;
        my $x = pop @moves;

        return if defined $map{$y}{$x};

        $max_x = $x if $x > $max_x;
        $max_y = $y if $y > $max_y;

        if ($value) {
            $map{$y}{$x} = '#';

            if ($state == 1) {
                $start_x = $x;
            }

            $state = 0;
            push @input, [$x+1, $y];
        }
        else {
            $map{$y}{$x} = '.';
            my $pt;
            if ($state == 0) {
                if (done($start_x, $y, $square_size)) {
                    my $i = $start_x;
                    my $j = $y - $square_size + 1;
                    $final_result = 10000 * $i + $j;
                    warn "Square (size:$square_size, @ [$i,$j]) - $final_result\n";
                    $done = 1 if $square_size++ == 100;
                }

                $pt = [$start_x, $y+1];
                $state = 1;
            }
            else {
                $pt = [$x+1, $y];
            }

            push @input, $pt;
        }
    });

$ic->set_read_cb(sub {
        my ($self) = @_;
        my $res = shift @{$input[0]};
        shift @input unless scalar(@{$input[0]});
        push @moves, $res;
        return $res;
    });

while (!$done) {
    $ic->run();
    $ic->reset();
}

print "$final_result\n";

sub done {
    my ($x, $y, $size) = @_;
    for my $pt ([$x,$y],[$x,$y-$size+1],[$x+$size-1,$y],[$x+$size-1,$y-$size+1]) {
        return 0 unless ($map{$pt->[1]}{$pt->[0]} // '') eq '#';
    }
    return 1;
}
