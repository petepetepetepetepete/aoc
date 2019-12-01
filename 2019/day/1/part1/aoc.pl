#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

print sum(map { int($_/3) - 2 } <>) . "\n";
