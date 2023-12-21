#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw/sum/;
use Memoize;
memoize qw/get_next/;
memoize qw/get_neighbours/;
use POSIX;

my $steps = shift;
my $stepsmod = $steps % 2;
my @m = map { chomp; [ split//, $_ ] } <>;
my $max_y = $#m;
my $max_x = $#{$m[0]};

my ($start) = grep { $m[$_->[1]][$_->[0]] eq 'S' } map { my $y=$_; map { [ $_, $y ] } (0..$max_x) } (0..$max_y);
my %grids = ('0,0' => {"$start->[0],$start->[1]" => 1});
my %prev;
my %cycles;

my %xxx;

for my $step (1..$steps) {
    my %newgrids;
    while (my ($k,$gpts) = each %grids) {
        my ($gx,$gy) = split /,/, $k;
        my @next = get_next(sort keys %$gpts);
        for my $next (@next) {
            my $ngx = $gx + floor($next->[0] / ($max_x+1));
            my $ngy = $gy + floor($next->[1] / ($max_y+1));

            my $nx = $next->[0] % ($max_x+1);
            my $ny = $next->[1] % ($max_y+1);
            $newgrids{"$ngx,$ngy"}{"$nx,$ny"} //= 1 unless exists $cycles{"$ngx,$ngy"};
        }
    }

    for my $k (keys %newgrids) {
        $prev{$k} //= [ 0, 0 ];
        my $gridcount = scalar(keys %{$newgrids{$k}});
        if ($prev{$k}[0] == $gridcount) {
            #warn "Detected looped in grid $k at step $step\n";
            my $stepmod = $step % 2;
            $cycles{$k} = $prev{$k}[$stepsmod ^ $stepmod];
            delete $newgrids{$k};
        }
        else {
            push @{$prev{$k}}, $gridcount;
            shift @{$prev{$k}};
        }
    }

    #for my $k (sort grep { !exists $grids{$_} } keys %newgrids) {
    #    my $nnn = join(',', sort keys %{$newgrids{$k}});
    #    warn "$step. grid($k) start: $nnn plots: " . scalar(keys %{$newgrids{$k}}) . "\n" if !exists $xxx{$nnn};
    #    $xxx{$nnn} //= 1;
    #}

    %grids = %newgrids;
    #warn "$step. grids:" . scalar(keys %grids) . " plots:" . sum(map { scalar(keys %$_) } values %grids) . "\n";
    #warn "$step. grid(0,0) plots: " . scalar(keys %{$grids{"0,0"}}) . "\n";
}

my $result = sum(map { scalar(keys %$_) } values %grids) + (sum(values %cycles) // 0);

print $result . "\n";

sub get_next {
    my @pts = map { [ split /,/, $_ ] } @_;
    my %newpts;

    for my $pt (@pts) {
        my @neighbours = get_neighbours(@$pt);
        $newpts{$_->[1]}{$_->[0]} //= 1 foreach @neighbours;
    }

    return map { my $y=$_; map { [ $_, $y ] } keys %{$newpts{$y}} } keys %newpts;
}

sub get_neighbours { 
    my ($x, $y) = @_;
    my @pts;
    for my $off ([-1,0],[1,0],[0,-1],[0,1]) {
        my $nx = $x + $off->[0];
        my $ny = $y + $off->[1];

        my $mx = $nx % ($max_x+1);
        my $my = $ny % ($max_y+1);

        next unless $m[$my][$mx] =~ m/^[S.]$/;
        push @pts, [$nx,$ny];
    }

    return @pts;
}

