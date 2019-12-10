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
            $input = $self->{read_cb}->($self);
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
            $self->{write_cb}->($self, $value);
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
            $self->{halt_cb}->($self);
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

    return bless {
        prog => [ split /,/, $prog ],
        ip => 0,
        relative_base => 0,
    }, $class;
}

sub set_read_cb {
    my ($self, $cb) = @_;

    if ($cb) {
        $self->{read_cb} = $cb;
    }
    else {
        delete $self->{read_cb};
    }
}

sub set_write_cb {
    my ($self, $cb) = @_;

    if ($cb) {
        $self->{write_cb} = $cb;
    }
    else {
        delete $self->{write_cb};
    }
}

sub set_halt_cb {
    my ($self, $cb) = @_;

    if ($cb) {
        $self->{halt_cb} = $cb;
    }
    else {
        delete $self->{halt_cb};
    }
}

sub set_pre_run_cb {
    my ($self, $cb) = @_;

    if ($cb) {
        $self->{pre_run_cb} = $cb;
    }
    else {
        delete $self->{pre_run_cb};
    }
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
    else {
        die "Invalid parameter type: $type";
    }
}

sub run {
    my $self = shift;

    if (ref($self->{pre_run_cb}) eq 'CODE') {
        $self->{pre_run_cb}->($self);
    }

    while (1) {
        my $res = $self->opcode();
        last if $res == -1;
    }
}

sub opcode {
    my ($self) = @_;

    my $ip = $self->{ip};
    my $opcode = $self->{prog}->[$ip] % 100;
    if (ref $opcodes{$opcode} eq 'CODE') {
        return $opcodes{$opcode}->($self);
    }
    else {
        die "Unknown opcode: $opcode ($self->{prog}->[$ip]) at offset=$ip";
    }
}

package main;

use Algorithm::Permute;

my $prog_file = shift;

my @readers;
my @writers;

my $max = -1;
my @seq = (5..9);
Algorithm::Permute::permute {
    for my $i (0..$#seq+2) {
        pipe(my $rh, my $wh) or die "Failed to pipe: $!";
        $rh->autoflush(1);
        $wh->autoflush(1);
        push @readers, $rh;
        push @writers, $wh;
    }
    close $readers[-1];

    my $res = calc_output_signal(@seq);
    $max = $res if $res > $max;

    @readers = ();
    @writers = ();
} @seq;

print "$max\n";

sub calc_output_signal {
    my (@seq) = @_;

    for my $i (0..$#seq) {
        if (my $pid = fork()) {
            close $readers[$i];
            close $writers[$i+1];

            if ($i == 0) {
                print {$writers[0]} "$seq[0]\n0\n";
            }
            if ($i == $#seq) {
                close $writers[0];
                close $writers[-1];

                my $in_fh = $readers[-2];
                chomp(my $res = <$in_fh>);
                close $readers[-2];
                return $res;
            }
        }
        else {
            die "Failed to fork: $!" unless defined $pid;

            my $w_i = $i < $#seq ? $i+1 : 0;

            close $readers[$_] for grep { $_ != $i } (0..$#readers);
            close $writers[$_] for grep { $_ != $i+1 && $_ != $w_i } (0..$#writers);

            my $ic = IntCode->new($prog_file);
            if ($i < $#seq) {
                $ic->set_pre_run_cb(
                    sub {
                        print {$writers[$i+1]} "$seq[$i+1]\n";
                    });
            }

            $ic->set_read_cb(
                sub {
                    my $in_fh = $readers[$i];
                    chomp(my $in = <$in_fh>);
                    return $in;
                });

            $ic->set_write_cb(
                sub {
                    my ($self, $value) = @_;
                    if ($i == $#seq) {
                        local $SIG{PIPE} = sub {
                            close $writers[0];
                            print {$writers[$i+1]} "$value\n";
                            close $writers[$i+1];
                        };
                        print {$writers[0]} "$value\n";
                    }
                    else {
                        print {$writers[$i+1]} "$value\n";
                    }
                });

            $ic->set_halt_cb(
                sub {
                    my ($self) = @_;
                    close $readers[$i];
                    close $writers[$i+1];
                });

            $ic->run();

            exit;
        }
    }
}
