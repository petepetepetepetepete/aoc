#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

my $tests = 0;

my $output = `perl aoc.pl t/in/1 10`;
my $expected_output = `cat t/expected/1`;
is $output, $expected_output, "Got expected output for perl ../../aoc.pl t/in/1 10";
$tests++;

$output = `perl aoc.pl t/in/2 100`;
$expected_output = `cat t/expected/2`;
is $output, $expected_output, "Got expected output for perl ../../aoc.pl t/in/2 100";
$tests++;

done_testing($tests);
