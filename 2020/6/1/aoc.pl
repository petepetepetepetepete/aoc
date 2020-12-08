#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum uniq/;

print sum(map { s/\n//g; scalar(uniq(split //)); } split(/\n\n/, join("", <>))) . "\n";
