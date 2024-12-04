#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/product sum/;

my $in = do { local $/; <> };
print sum(map { product(split /,/) } $in =~ m/mul\((\d{1,3},\d{1,3})\)/g) . "\n";
