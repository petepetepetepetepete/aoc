#!/usr/bin/env perl

use File::Path qw/make_path/;

my ($year, $day, $part) = @ARGV;
die "Requires year, day, and part" unless $year && $day && $part;

my $dir = "$year/$day/$part";
die "Directory $dir already exists" if -d $dir;

make_path $dir or die "Failed to make_path $dir: $!";

open my $fh, ">$dir/Makefile" or die "Failed to open $dir/Makefile for write: $!";
print $fh <<EOF;
solve: ../input
	\@perl aoc.pl < \$<

test:
	\@prove -mvw t/examples.t

../input: ../../../.cookie
	curl -H"\$\$(cat \$<)" -o \$\@ https://adventofcode.com/$year/day/$day/input
EOF
close $fh;

open $fh, ">$dir/aoc.pl" or die "Failed to open $dir/aoc.pl for write: $!";
print $fh <<'EOF';
#!/usr/bin/env perl

use strict;
use warnings;

while (my $line = <>) {
}

EOF
close $fh;

make_path "$dir/t" or die "Failed to make_path $dir/t: $!";
open $fh, ">$dir/t/examples.t" or die "Failed to open $dir/t/examples.t for write: $!";
print $fh <<'EOF';
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

    my $output = `perl ../../aoc.pl < $_`;
    my $expected_output = `cat $expected_file`;

    is $output, $expected_output, "Got expected output for $name";
    $tests++;
}
EOF
close $fh;

for my $d (qw/in expected/) {
    make_path "$dir/t/$d" or die "Failed to make_path $dir/t/$d: $!";
}

my $test = 1;
while (1) {
    print "Enter example input (EOF when no examples remain):\n";
    my @input = <STDIN>;
    last unless @input;

    open $fh, ">$dir/t/in/$test" or die "Failed to open $dir/t/in/$test for write: $!";
    print $fh join('', @input);
    close $fh;

    print "Enter expected output:\n";
    @input = <STDIN>;
    die "Must provide expected output" unless @input;

    open $fh, ">$dir/t/expected/$test" or die "Failed to open $dir/t/expected/$test for write: $!";
    print $fh join('', @input);
    close $fh;

    $test++;
}

my $readme = "$dir/../README.md";
exit 0 if -f $readme;

open my $fh, ">$readme" or die "Failed to open $readme for write: $!";
print $fh <<EOF;
[$year day $day puzzle](https://adventofcode.com/$year/day/$day)
EOF
close $fh;
