#!/usr/bin/env perl

use strict;
use warnings;

# after 65 steps, number of grids increases every 131 steps
# 26501365 - 65 = 26501300
# 26501300 / 131 = 202300
# progression of number of grids that contain the number of reachable garden plots:
# loop count:           1   2   3   4   5   6
# 5563/5569/5587/5593:  1   1   1   1   1   1       loopcount^0
# 7388:                 1   4   9   16  25  36      loopcount^2
# 938/948/949/959:      1   1   1   1   1   1       loopcount^0
# 6472/6492/6496/6498:  0   1   2   3   4   5       loopcount-1
# 7401:                 0   1   4   9   16  25      (loopcount-1)^2

my $loops = 202300;

my $result = 5563 + 5569 + 5587 + 5593;
$result += 7388 * $loops**2;
$result += $loops * (938 + 948 + 949 + 959);
$result += ($loops - 1) * (6472 + 6492 + 6496 + 6498);
$result += 7401 * ($loops-1)**2;

print $result . "\n";

