#!/usr/bin/env perl

use strict;
use warnings;

use POSIX;

my $in_file = shift or die "input file required";

my %funcs;

open my $fh, "<$in_file" or die "Failed to open $in_file for read: $!";
while (my $line = <$fh>) {
    chomp $line;
    my ($left, $right) = split / => /, $line;
    my @equals = map { my ($count, $chem) = split / /, $_; { chem => $chem, count => $count } } split /, /, $left;
    my ($r_count, $chem) = split / /, $right;

    die if exists $funcs{$chem};
    $funcs{$chem} = sub {
        my ($system, $count) = @_;

        $system->{$chem} //= 0;
        my $mult = ceil($count / $r_count);
        for my $x (@equals) {
            $system->{$x->{chem}} //= 0;
            my $required = $mult * $x->{count} - $system->{$x->{chem}};
            $funcs{$x->{chem}}->($system, $required) if $required > 0;
            $system->{$x->{chem}} -= $mult * $x->{count};
        }

        $system->{$chem} += $mult * $r_count;

        return $system->{total_ore} // 0;
    };
}
close $fh;

$funcs{ORE} = sub {
    my ($system, $count) = @_;

    $system->{ORE} += $count;
    $system->{total_ore} += $count;
};

my %system;
print $funcs{FUEL}->(\%system, 1) . "\n";

