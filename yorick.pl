#!/usr/bin/perl -w

# =================================================================
#
# POE and POE::Component::IRC are required. Use the CPAN module to
# install this:
# perl -MCPAN -eshell
# cpan> install POE
# cpan> install POE::Component::IRC

use strict;


  # A simple Rot13 'encryption' bot

  use warnings;
  use POE qw(Component::IRC);

  my $nickname = 'Yorick' . $$;
  my $ircname = 'Yorick the magic todger bot';
  my $ircserver = 'irc.lagnet.org.za';
  my $port = 6667;

  my @channels = ( '#adult-games' ); # ( '#Fnord', '#Foo', '#Bar' );

  # We create a new PoCo-IRC object and component.
  my $irc = POE::Component::IRC->spawn( 
	nick => $nickname,
	server => $ircserver,
	port => $port,
	ircname => $ircname,
  ) or die "Oh noooo! $!";

  POE::Session->create(
	package_states => [
		'main' => [ qw(_default _start irc_001 irc_public) ],
	],
	heap => { irc => $irc },
  );

  $poe_kernel->run();
  exit 0;

  sub _start {
    my ($kernel,$heap) = @_[KERNEL,HEAP];

    # We get the session ID of the component from the object
    # and register and connect to the specified server.
    my $irc_session = $heap->{irc}->session_id();
    $kernel->post( $irc_session => register => 'all' );
    $kernel->post( $irc_session => connect => { } );
    undef;
  }

  sub irc_001 {
    my ($kernel,$sender) = @_[KERNEL,SENDER];

    # Get the component's object at any time by accessing the heap of
    # the SENDER
    my $poco_object = $sender->get_heap();
    print "Connected to ", $poco_object->server_name(), "\n";

    # In any irc_* events SENDER will be the PoCo-IRC session
    $kernel->post( $sender => join => $_ ) for @channels;
    undef;
  }

  sub irc_public {
    my ($kernel,$sender,$who,$where,$what) = @_[KERNEL,SENDER,ARG0,ARG1,ARG2];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where->[0];

    if ( my ($rot13) = $what =~ /^rot13 (.+)/ ) {
	$rot13 =~ tr[a-zA-Z][n-za-mN-ZA-M];
	$kernel->post( $sender => privmsg => $channel => "$nick: $rot13" );
    }
    undef;
  }

  # We registered for all events, this will produce some debug info.
  sub _default {
    my ($event, $args) = @_[ARG0 .. $#_];
    my @output = ( "$event: " );

    foreach my $arg ( @$args ) {
        if ( ref($arg) eq 'ARRAY' ) {
                push( @output, "[" . join(" ,", @$arg ) . "]" );
        } else {
                push ( @output, "'$arg'" );
        }
    }
    print STDOUT join ' ', @output, "\n";
    return 0;
  }

