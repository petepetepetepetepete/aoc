#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my @nums = split /,/, <>;
<>; # read blank line

my @boards;
my @board;
while (my $line = <>) {
    chomp $line;
    if ($line eq '') {
        push @boards, [ @board ];
        @board = ();
        next;
    }
    $line =~ s/^ *//;
    $line =~ s/ *$//;
    push @board, [ split / +/, $line ];
}
push @boards, [ @board ];

for my $num (@nums) {
    draw_num($num, \@boards);

    if (@boards == 1) {
        my $res = check_board($boards[0], $num);
        if ($res != -1) {
            print $res . "\n";
            last;
        }
    }
    else {
        my @new_boards;
        for my $board (@boards) {
            my $res = check_board($board, $num);
            if ($res == -1) {
                push @new_boards, $board;
            }
        }

        @boards = @new_boards;
    }
}

sub draw_num {
    my ($n, $boards) = @_;
    for my $board (@$boards) {
        @$board = map { my $i = $_; [ map { $board->[$i][$_] != $n ? $board->[$i][$_] : -1 } (0..4) ] } (0..4);
    }
}

sub check_board {
    my ($board, $num) = @_;

    for my $i (0..4) {
        if (scalar(grep { $board->[$i][$_] < 0 } (0..4)) == 5 || scalar(grep { $board->[$_][$i] < 0 } (0..4)) == 5) {
            return $num * sum(map { my $j = $_; sum(map { $board->[$j][$_] > 0 ? $board->[$j][$_] : 0 } (0..4)) } (0..4));
        }       
    }
    
    return -1;
}
