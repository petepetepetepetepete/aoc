#!/usr/bin/env perl

use strict;
use warnings;

package IntCode;

sub new {
    my ($class, $prog_file, $phase) = @_;
    die unless $class && $prog_file;

    open my $fh, "<$prog_file" or die "Failed to open $prog_file for read: $!";
    my $prog = <$fh>;
    chomp $prog;
    close $fh;

    return bless {
        prog => [ split /,/, $prog ],
        phase => $phase,
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

    my $out_fh = $self->{out_fh} // *STDOUT;
    print $out_fh "$self->{phase}\n" if defined $self->{phase};

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

use Algorithm::Permute;

my $prog_file = shift;

my @readers;
my @writers;

my $max = -1;
my @seq = (0..4);
Algorithm::Permute::permute {
    for my $i (0..5) {
        pipe(my $rh, my $wh) or die "Failed to pipe: $!";
        push @readers, $rh;
        push @writers, $wh;
    }

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
                close $writers[0];
            }
            if ($i == $#seq) {
                my $in_fh = $readers[-1];
                chomp(my $res = <$in_fh>);
                close $readers[-1];
                return $res;
            }
        }
        else {
            die "Failed to fork: $!" unless defined $pid;

            close $readers[$_] for grep { $_ != $i } (0..$#readers);
            close $writers[$_] for grep { $_ != $i+1 } (0..$#writers);

            my $ic = IntCode->new($prog_file, $i < $#seq ? $seq[$i+1] : ());
            $ic->set_in_fh($readers[$i]);
            $ic->set_out_fh($writers[$i+1]);
            $ic->run();
            exit;
        }
    }
}
