#!/usr/bin/env perl

use strict;
use warnings;

package IntCode;

sub new {
    my ($class, $prog_file) = @_;
    die unless $class && $prog_file;

    open my $fh, "<$prog_file" or die "Failed to open $prog_file for read: $!";
    my $prog = <$fh>;
    chomp $prog;
    close $fh;

    return bless {
        prog => [ split /,/, $prog ],
        ip => 0,
        relative_base => 0,
        opcodes => {
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
                my $in_fh = $self->{in_fh} // *STDIN;
                my $input = <$in_fh>;
                chomp $input;
                $self->set_value(1, $input);
                $self->{ip} += 2;
            },
            4 => sub {
                my ($self) = @_;
                my $out_fh = $self->{out_fh} // *STDOUT;
                print $out_fh $self->get_value(1) . "\n";
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
                return -1;
            }
        },
    }, $class;
}

sub set_in_fh {
    my ($self, $in_fh) = @_;
    $self->{in_fh} = $in_fh;
}

sub set_out_fh {
    my ($self, $out_fh) = @_;
    $self->{out_fh} = $out_fh;
}

sub set_value {
    my ($self, $offset, $value) = @_;

    my $ip = $self->{ip};
    my $opcode = $self->{prog}->[$ip];
    my $type = ($opcode / (10 ** ($offset + 1))) % 10;
    if ($type == 0) {
        $self->{prog}->[$self->{prog}->[$ip+$offset]] = $value;
    }
    elsif ($type == 1) {
        $self->{prog}->[$ip+$offset] = $value;
    }
    elsif ($type == 2) {
        $self->{prog}->[$self->{relative_base} + $self->{prog}->[$ip+$offset]] = $value;
    }
    else {
        die "Invalid parameter type: $type";
    }
}

sub get_value {
    my ($self, $offset) = @_;
    my $ip = $self->{ip};
    my $opcode = $self->{prog}->[$ip];
    my $type = ($opcode / (10 ** ($offset + 1))) % 10;
    if ($type == 0) {
        return $self->{prog}->[$self->{prog}->[$ip+$offset]] // 0;
    }
    elsif ($type == 1) {
        return $self->{prog}->[$ip+$offset] // 0;
    }
    elsif ($type == 2) {
        return $self->{prog}->[$self->{relative_base} + $self->{prog}->[$ip+$offset]] // 0;
    }
    else {
        die "Invalid parameter type: $type";
    }
}

sub run {
    my $self = shift;
    while (1) {
        my $res = $self->opcode();
        last if $res == -1;
    }
}

sub opcode {
    my ($self) = @_;

    my $ip = $self->{ip};
    my $opcode = $self->{prog}->[$ip] % 100;
    if (ref $self->{opcodes}{$opcode} eq 'CODE') {
        return $self->{opcodes}{$opcode}->($self);
    }
    else {
        die "Unknown opcode: $opcode ($self->{prog}->[$ip]) at offset=$ip";
    }
}

package main;

my $ic = IntCode->new(shift);
$ic->run();
