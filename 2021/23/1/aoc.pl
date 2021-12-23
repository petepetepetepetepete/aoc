#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/any max min none/;
use Storable qw/dclone/;

my %cache;
my %cost = ( A => 1, B => 10, C => 100, D => 1000 );
my %cols = ( A => 2, B => 4, C => 6, D => 8);
my %in_dist = (0 => 2, 1 => 1);
my %out_dist = (2 => 1, 1 => 2);
my %rooms;
@{$rooms{hallway}} = ('.') x 11;
while (my $line = <>) {
    chomp $line;
    if ($line =~ m/#(\w)#(\w)#(\w)#(\w)#/) {
        push @{$rooms{A}}, $1;
        push @{$rooms{B}}, $2;
        push @{$rooms{C}}, $3;
        push @{$rooms{D}}, $4;
    }
}

my $room_size = scalar(@{$rooms{A}});

print solve(%rooms) . "\n";

sub solve {
    my (%state) = @_;
    return 0 if done(%state);

    my $key = join '|', map { join '', @{$state{$_}}  } qw/hallway A B C D/;
    return $cache{$key} if exists $cache{$key};

    my @scores;
    for my $i (0..$#{$state{hallway}}) {
        my $c = $state{hallway}[$i];
        next if $c eq '.';
        if (room_ready($c, %state)) {
            my $d = path($i, $cols{$c}, %state);
            next unless defined $d;
            $d += $in_dist{scalar(@{$state{$c}})};
            #$d += scalar(@{$state{$c}}) == 1 ? 2 : 1;
            $d *= $cost{$c};

            my %new_state = %{ dclone(\%state) };
            $new_state{hallway}[$i] = '.';
            push @{$new_state{$c}}, $c;

            my $s = solve(%new_state);
            if (defined $s) {
                push @scores, $d + $s;
            }
        }
    }

    for my $k (qw/A B C D/) {
        next unless any { $_ ne $k } @{$state{$k}}; # skip this room if it only contains the right letter
        my $i = $cols{$k};
        my $c = $state{$k}[0];
        for my $j (0..10) {
            next if grep { $j == $_ } values %cols; # Can't stop outside a room
            next if $state{hallway}[$j] ne '.'; # Can't move to an non-empty space
            my $d = path($i, $j, %state);
            next unless defined $d;
            #$d += scalar(@{$state{$k}}) == 1 ? 2 : 1;
            $d += $out_dist{scalar(@{$state{$k}})};
            $d *= $cost{$c};

            my %new_state = %{ dclone(\%state) };
            $new_state{hallway}[$j] = shift @{$new_state{$k}};
            
            my $s = solve(%new_state);
            if (defined $s) {
                push @scores, $d + $s;
            }
        }
    }

    $cache{$key} = min(@scores);
    return $cache{$key};
}

sub room_ready {
    my ($c, %state) = @_;
    return none { $_ ne $c } @{$state{$c}};
}

sub path {
    my ($i, $tgt, %state) = @_;
    my @path = min($i, $tgt)..max($i, $tgt);
    @path = reverse @path unless $path[0] == $i;
    shift @path; # remove start position
    return if any { $_ ne '.' } map { $state{hallway}[$_] } @path;
    return scalar(@path);
}

sub done {
    my %r = @_;
    my $key = join '|', map { join '', @{$r{$_}}  } qw/hallway A B C D/;
    for my $k (keys %r) {
        next if $k eq 'hallway';
        return 0 unless scalar(grep { $_ eq $k } @{$r{$k}}) == $room_size;
    }
    return 1;
}
