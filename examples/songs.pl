#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Encode;

use LWP::Simple;

use Project::Libs;
use MyArduino;
use Device::Firmata::Constants qw(:all);

my $url     = 'http://www-masu.ist.osaka-u.ac.jp/~kakugawa/Hyaku/hyaku.txt';
my $content = get $url;

my %seen;
my @songs = grep {
    my ($number) = /^(\d+)/;
    !$seen{$number}++;
} grep { /^\d{1,3}\s+.+$/ } split /[\r\n]/, decode('euc-jp', $content);

my $input   = 6;
my $output  = 13;
my $arduino = MyArduino->new;
   $arduino->firmata->pin_mode($input,  PIN_INPUT);
   $arduino->firmata->pin_mode($output, PIN_OUTPUT);
   $arduino->firmata->digital_write($input, PIN_HIGH);

while (1) {
    $arduino->firmata->poll;

    if ($arduino->firmata->digital_read($input) == PIN_LOW) {
        my $message = 'Arduino: ' . $songs[int(rand(100))];

        eval { $arduino->twitter->update($message) };

        if ($@) {
            warn $@;
        }
        else {
            warn "updated: $message";
        }
    }

    select undef, undef, undef, 0.01;
}
