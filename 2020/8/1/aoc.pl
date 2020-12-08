#!/usr/bin/env perl

use strict;
use warnings;

package BootCode;

sub new {
    my ($class, $prog_file) = @_;
    die unless $class && $prog_file;

    open my $fh, "<$prog_file" or die "Failed to open $prog_file for read: $!";
    my $prog = [ map { chomp; [ split / /, $_ ] } <> ];
    close $fh;

    return bless {
        prog => $prog,
        ip => 0,
        executed => {},
        accumulator => => 0,
        opcodes => {
            acc => sub {
                my ($self, $arg) = @_;
                $self->{accumulator} += $arg;
                $self->{ip}++;
            },
            jmp => sub {
                my ($self, $arg) = @_;
                $self->{ip} += $arg;
            },
            nop => sub {
                my ($self, $arg) = @_;
                $self->{ip}++;
            },
        },
    }, $class;
}

sub run {
    my $self = shift;

    while (!exists $self->{executed}{$self->{ip}}) {
        $self->{executed}{$self->{ip}} = 1;
        $self->{opcodes}{$self->{prog}[$self->{ip}][0]}->($self, $self->{prog}[$self->{ip}][1]);
    }

    return $self->{accumulator};
}

1;

my $bc = BootCode->new('/dev/stdin');
print $bc->run() . "\n";
