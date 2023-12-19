#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/product sum/;

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
                my ($lower, $upper) = @{$rating->{$lhs}};
                my %non = map { $_ => [ @{$rating->{$_}} ] } grep { $_ ne $lhs } keys %$rating;
                if ($op eq '>') {
                    # return [], func [$lower,$upper]
                    if ($rhs < $lower) {
                        $workflows{$action}->({ %non, $lhs => [$lower,$upper] });
                        return { %non, $lhs => [] };
                    }
                    # return [$lower,$upper], func []
                    elsif ($rhs >= $upper) {
                        $workflows{$action}->({ %non, $lhs => [] });
                        return { %non, $lhs => [$lower,$upper] };
                    }
                    # return [$lower,$rhs], func [$rhs+1,$upper]
                    else {
                        $workflows{$action}->({ %non, $lhs => [$rhs+1,$upper] });
                        return { %non, $lhs => [$lower,$rhs] };
                    }
                }
                elsif ($op eq '<') {
                    # return [$lower,$upper], func []
                    if ($rhs < $lower) {
                        $workflows{$action}->({ %non, $lhs => [] });
                        return { %non, $lhs => [$lower,$upper] };
                    }
                    # return [], func [$lower,$upper]
                    elsif ($rhs >= $upper) {
                        $workflows{$action}->({ %non, $lhs => [$lower,$upper] });
                        return { %non, $lhs => [] };
                    }
                    # return [$rhs,$upper], next [$lower,$rhs-1]
                    else {
                        $workflows{$action}->({ %non, $lhs => [$lower,$rhs-1] });
                        return { %non, $lhs => [$rhs,$upper] };
                    }
                }

                die;
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
            $rating = $f->($rating);
        }
    };
}

$workflows{in}->({x => [1, 4000], m => [1, 4000], a => [1, 4000], s => [1, 4000]});
print sum(map { my $a=$_; product(map { $a->{$_}[1]-$a->{$_ }[0]+1 } keys %$a) } @accepted) . "\n";

