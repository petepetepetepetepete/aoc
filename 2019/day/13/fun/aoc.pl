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

use List::Util qw/min max/;
use Term::ANSIColor;
use Term::Cap;
use Term::ReadKey;
use Time::HiRes qw/sleep/;

my $prog_file = shift;
my $cheat = shift;

my $terminal = Tgetent Term::Cap;
system('clear');
ReadMode 4;

my %map;
my $write_count = 0;

my $ic = IntCode->new($prog_file);

my %pos = map { $_ => 0 } (3,4);
my $max_x = 0;
my $max_y = 0;
my ($x, $y, $score);

$ic->set_pre_run_cb(sub {
        my ($self) = @_;
        $self->{prog}->{0} = 2;
    });

$ic->set_write_cb(sub {
        my ($self, $value) = @_;
        my $i = $write_count++ % 3;

        if ($i == 0) {
            $x = $value;
            $max_x = max($x, $max_x);
        }
        elsif ($i == 1) {
            $y = $value;
            $max_y = max($y, $max_y);
        }
        elsif ($i == 2) {
            if ($x == -1 && $y == 0) {
                $score = $value;
            }
            else {
                $map{$y}{$x} = $value;
                if ($value == 3 || $value == 4) {
                    $pos{$value} = $x;
                }
            }
        }
    });

$ic->set_read_cb(sub {
        draw_map(\%map);
        return $pos{4} <=> $pos{3} if $cheat;
        my $c = ReadKey(0);
        return -1 if $c eq 'a';
        return 0 if $c eq 's';
        return 1 if $c eq 'd';
        die;
    });

$ic->set_halt_cb(sub {
        print $terminal->Tgoto('cm', 0, $max_y + 2);
        print "Score: $score\n";
        ReadMode 0;
    });

$ic->run();

$|++;
sub draw_map {
    my ($map) = @_;

    my %char_map = (
        0 => ' ',
        1 => '█',
        2 => '▄',
        3 => '▔',
        4 => 'o',
    );
    my @colors = (
        color('red'),
        color('green'),
        color('yellow'),
        color('blue'),
        color('magenta'),
        color('cyan'),
    );
    for my $y (0..$max_y) {
        for my $x (0..$max_x) {
            print $terminal->Tgoto('cm', $x, $y);
            my $c = $map->{$y}{$x} // 0;
            if ($c == 2) {
                print $colors[$y % scalar(@colors)];
            }
            print $char_map{$c};
            print color('reset');
        }
    }

    print $terminal->Tgoto('cm', 0, $max_y + 2);
    print "Score: $score\n";

    sleep 0.03;
}

1;
