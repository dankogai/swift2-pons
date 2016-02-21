#!/usr/bin/env perl6
use v6;
use Bench;

sub fact {
    [*] 1...$^n
}

sub MAIN($count=0) {
    say fact 20;
    say fact 42;
    Bench.new.cmpthese($count, {
        '20!/19!'  => sub { fact(20) / fact(19) == 20   or die },
        '100!/99!' => sub { fact(100) / fact(99) == 100 or die }
    });
}
