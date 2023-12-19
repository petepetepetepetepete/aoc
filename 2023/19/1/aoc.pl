#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;

my $input = join('', <>);
my ($workflows, $ratings) = split /\n\n/, $input;

my @accepted;
my @rejected;
my %workflows;
$workflows{A} = sub {
    my ($rating) = @_;
    push @accepted, $rating;
    return 1;
};
$workflows{R} = sub {
    my ($rating) = @_;
    push @rejected, $rating;
    return 1;
};
for my $workflow (split /\n/, $workflows) {
    my ($name, $rules) = $workflow =~ m/^(\w+)\{(.+)\}$/;
    die $workflow unless defined $name and defined $rules;
    my @func;
    for my $rule (split /,/, $rules) {
        if ($rule =~ m/^(\w+)([<>])(\w+):(\w+)$/) {
            my ($lhs, $op, $rhs, $action) = ($1, $2, $3, $4);
            push @func, sub {
                my ($rating) = @_;
                if ($op eq '>') {
                    if ($rating->{$lhs} > $rhs) {
                        return $workflows{$action}->($rating);
                    }
                }
                elsif ($op eq '<') {
                    if ($rating->{$lhs} < $rhs) {
                        return $workflows{$action}->($rating);
                    }
                }
                else {
                    die $op;
                }
                return 0;
            };
        }
        elsif ($rule =~ m/^(\w+)$/) {
            my $action = $1;
            push @func, sub {
                my ($rating) = @_;
                return $workflows{$action}->($rating);
            };
        }
        else {
            die $rule;
        }
    }

    $workflows{$name} = sub {
        my ($rating) = @_;
        for my $f (@func) {
            my $result = $f->($rating);
            return $result if $result;
        }
    };
}

for my $rating_str (split /\n/, $ratings) {
    $rating_str =~ s/[{}]//g;
    my %rating = map { my ($k,$v) = split /=/, $_; $k => $v  } split /,/, $rating_str;
    $workflows{in}->(\%rating);
}

print sum(map { sum(values %$_) } @accepted) . "\n";
