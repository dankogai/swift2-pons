#!/usr/bin/env perl
use v5.18;
use warnings;
use Benchmark qw(:all);
use Math::BigInt    # try => 'GMP';
  warn Math::BigInt->config->{lib};

sub fact {
    my $result = 1;
    $result *= $_ for 1 .. $_[0];
    $result;
}

sub bfact {
    my $result = Math::BigInt->new(1);
    $result->bmul($_) for 1 .. $_[0];
    $result;
}

my $count = shift || 0;

say "20! == ", fact 20;
say "42! == ", bfact 42;

cmpthese timethese $count => {
    'native' => sub { fact(20) / fact(19) == 20   or die },
    'BigInt' => sub { bfact(20) / bfact(19) == 20 or die }
};

cmpthese timethese $count => {
    '20!/19!'  => sub { bfact(20) / bfact(19) == 20   or die },
    '100!/99!' => sub { bfact(100) / bfact(99) == 100 or die }
};
