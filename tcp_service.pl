#!/usr/bin/perl -w

# Simple TCP Service that will help to reveal VirtualBox bug.
# Run this on other machine than VirtualBox!
# Based on: https://dev.to/thibaultduponchelle/perl-tcp-clientserver-sample-code-4pnm

use strict;
use warnings;

use IO::Socket::INET;
# auto-flush on socket
$| = 1;


# Creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => 9999,
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "Cannot create socket $!\n" unless $socket;

$SIG{INT} = sub {
       	$socket->close(); 
	print "Server exting on user request...\n";
	exit 0;
};

printf "Server listening on %s:%d...\n",$socket->sockhost(), $socket->sockport();
print  "Press Ctrl-C to exit...\n";
while(1) {
	my $client_socket = $socket->accept();

	# Get information about a newly connected client
	my $client_address = $client_socket->peerhost();

	# Send small chunk of data and immediately close connection
	my $data = "ABCDEFGH";
	my $exp_len = length($data);
	my $ret = $client_socket->send($data, $exp_len);
	die "ERROR: send(): $!" unless defined $ret;
	die "ERROR: send(): send only $ret out of $exp_len bytes" unless $ret == $exp_len;
	$client_socket->close();
	my $ts = localtime(time); # from https://stackoverflow.com/a/12644427
	print "$ts OK: responded to $client_address with '$data'\n";
}
# should be never reached
exit 1;
