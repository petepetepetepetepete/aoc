#!/usr/bin/env perl

use strict;
use warnings;

use File::Find;
use Test::More;

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;

my $tests = 0;
# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, 't/in/');
done_testing($tests);
exit;

sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    return unless lstat($_) && -f _;

    my $expected_file = "../expected/$_";
    return unless -f $expected_file;

    my $arg = '';
    $arg = `cat ../arg/$_` if -f "../arg/$_";
    chomp $arg;

    my $output = `perl ../../aoc.pl $arg < $_`;
    my $expected_output = `cat $expected_file`;

    is $output, $expected_output, "Got expected output for $name";
    $tests++;
}
