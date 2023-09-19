#!/usr/bin/perl -w

# PERL client to demonstrace VirtualBox NAT/SLIRP bug
# run this code in VirtualBox Guest on NAT Interface against tcp_service.pl running on other host
# Code based on:
# - https://dev.to/thibaultduponchelle/perl-tcp-clientserver-sample-code-4pnm
# - https://perldoc.perl.org/IO::Socket::INET

use strict;
use warnings;
use Carp;
use IO::Socket qw(AF_INET AF_UNIX SOCK_STREAM SHUT_WR);

# auto-flush on socket
$| = 1;

sub safe_print
{
        croak "Unexpected number of arguments: ".scalar @_ if scalar @_ != 1;
        my ($str) = @_;
        # https://stackoverflow.com/questions/66291247/how-can-i-translate-non-printable-ascii-chars-to-readable-text-with-perl
        $str =~ s/([^[:print:]]|\\])/ sprintf("\\x%02x",ord($1)) /eg;
        return $str;
}

my $REMOTE_PORT = 9999;
my $Iterations = 1;
my $SLEEP_TIME = 1;

die "Usage: $0 IP_OF_TCP_SERVER [ ITERATIONS ]" unless scalar @ARGV >=1 && scalar @ARGV <=2;
my $ServerIP = $ARGV[0];
$Iterations = $ARGV[1] if scalar @ARGV >=2;

my $i=0;

while($i<$Iterations){
	$i++;
	print "Iteration #$i...\n";
	# Create a connecting socket
	my $client = IO::Socket->new (
		Domain => AF_INET,
		Type => SOCK_STREAM,
		PeerHost => $ServerIP,
		PeerPort => $REMOTE_PORT,
		Proto => 'tcp',
	    ) || die "Can't create socket to connect t '$ServerIP:$REMOTE_PORT' : $@";

	printf("  Connected from %s:%d to %s:%d.\n",
		$client->sockhost(), $client->sockport(), $client->peerhost(), $client->peerport());

	my $data;
	my $exp_data = "ABCDEFGH";
	my $exp_len = length($exp_data); # expected to read this number of bytes

	my $ret = $client->recv($data,$exp_len);
	die "ERROR: recv(): $!" unless defined $ret;
	printf("  <- data from server: '%s' %d bytes\n", safe_print($data), length($data));
	# FIXME: such small chunk of data should arrive at once.
	die sprintf("Unexpected data '%s' <> '%s'",$data,$exp_data) unless $data eq $exp_data;
	print "  Data OK.\n";
	print "  Closing connection...\n";
	$client->close();
	# from: https://stackoverflow.com/a/896928
	select(undef, undef, undef,0.01);
}

print "OK: Exiting after $i iterations...\n";
exit 0
