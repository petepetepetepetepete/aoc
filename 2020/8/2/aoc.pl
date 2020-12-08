#!/usr/bin/env perl

use strict;
use warnings;

package BootCode;

my %opcodes = (
    acc => sub {
        my ($self) = @_;
        my $arg = $self->{prog}{$self->{ip}}[1];
        $self->{accumulator} += $arg;
        delete $self->{prog}{$self->{ip}} if $self->{loop_detection};
        $self->{ip}++;
    },
    jmp => sub {
        my ($self) = @_;
        my $arg = $self->{prog}{$self->{ip}}[1];
        delete $self->{prog}{$self->{ip}} if $self->{loop_detection};
        $self->{ip} += $arg;
    },
    nop => sub {
        my ($self) = @_;
        delete $self->{prog}{$self->{ip}} if $self->{loop_detection};
        $self->{ip}++;
    },
);

sub new {
    my ($class, $prog_file, %opts) = @_;
    die unless $class && $prog_file;

    open my $fh, "<$prog_file" or die "Failed to open $prog_file for read: $!";
    my $i = 0;
    my $prog = { map { chomp; $i++ => [ split / /, $_ ] } <> };
    close $fh;

    return bless {
        %opts,
        prog => $prog,
        ip => 0,
        max_ip => $i-1,
        executed => {},
        accumulator => => 0,
    }, $class;
}

sub is_complete {
    my $self = shift;

    return $self->{ip} > $self->{max_ip};
}

sub opcode {
    my $self = shift;

    my $ip = $self->{ip};
    my $instr = $self->{prog}{$ip};
    die "Unknown instruction \@$ip" unless defined $instr;

    my $opcode = $instr->[0];
    die "Unknown opcode: $opcode ($instr) at offset=$ip" unless ref $opcodes{$opcode} eq 'CODE';

    return $opcodes{$opcode}->($self);
}

sub run {
    my $self = shift;

    while (!$self->is_complete()) {
        my $res = $self->opcode();
    }

    return $self->{accumulator};
}

1;

use Storable 'dclone';

my $bc = BootCode->new('/dev/stdin', loop_detection => 1);

my %h = ('jmp' => 'nop', 'nop' => 'jmp');
for my $i (grep { exists $h{$bc->{prog}{$_}[0]} } (0..$bc->{max_ip}-1)) {
    my $bc2 = dclone($bc);
    $bc2->{prog}{$i}[0] = $h{$bc2->{prog}{$i}[0]};
    eval {
        print $bc2->run() . "\n";
    };
    last unless $@;
}

