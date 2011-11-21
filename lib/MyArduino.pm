package MyArduino;
use Mouse;
use YAML::Tiny;
use Net::Twitter::Lite;

use Project::Libs;
use Device::Firmata;

has device => (
    is      => 'rw',
    isa     => 'Str',
    default => '/dev/tty.SLAB_USBtoUART',
);

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { YAML::Tiny->read('local/twitter.yml')->[0] },
);

has twitter => (
    is      => 'ro',
    isa     => 'Net::Twitter::Lite',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $twitter = Net::Twitter::Lite->new(
            consumer_key    => $self->config->{consumer_key},
            consumer_secret => $self->config->{consumer_secret},
        );
        $twitter->access_token($self->config->{access_token});
        $twitter->access_token_secret($self->config->{access_token_secret});
        $twitter;
    },
);

has firmata => (
    is      => 'ro',
    isa     => 'Device::Firmata::Platform',
    lazy    => 1,
    default => sub {
        Device::Firmata->open(shift->device) or die qq{Couldn't connect to Firmata server.}
    },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

!!1;

