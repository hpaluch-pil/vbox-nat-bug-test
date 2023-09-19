# Demo of VirtualBox NAT/SLIRP bug

There is a bug when using VirtualBox "NAT" interface (but NOT "NAT Network") with any
king of guest (Linux, Windows,...) and Windows Host.

After few tries NAT/SLIRP will remove 1st byte of response and truncate data to be 1 byte less.
- expected data: "ABCDEFGH"
- received data  "BCDEFGH"

How to reproduce:
- run `./tcp_service.pl` on Linux remote machine
- run `./tcp_client.pl SERVER_IP 9999` in VirtualBox Guest (Linux preferred) using "NAT" Interface.


After several good iterations:
```
Iteration #34...
  Connected from 10.0.2.15:37258 to 192.168.10.54:9999.
  <- data from server: 'ABCDEFGH' 8 bytes
  Data OK.
  Closing connection...
```

There will sooner or later occur this error:
```
Iteration #35...
  Connected from 10.0.2.15:37270 to 192.168.10.54:9999.
  <- data from server: 'BCDEFGH' 7 bytes
Unexpected data 'BCDEFGH' <> 'ABCDEFGH' at ./tcp_client.pl line 59.
```

Where 1st byte of response is entirely missing and response is
1 byte shorter.

# Cause

SLIRP Layer (that provides user-space TCP UDP emulation and NAT using BSD libalias) closes remote
connection before received data are correctly processed. Solution is to skip socket
close until socket data are properly processed as Established.

# Fix

Experimental patch is under [vbox-patches/close-fix-slirp.c.patch](vbox-patches/close-fix-slirp.c.patch])

# Resources

Reported here: https://www.virtualbox.org/ticket/21850

Provided PERL scripts based on various Internet resources, including:
- https://dev.to/thibaultduponchelle/perl-tcp-clientserver-sample-code-4pnm
- https://perldoc.perl.org/IO::Socket::INET
- https://stackoverflow.com/questions/66291247/how-can-i-translate-non-printable-ascii-chars-to-readable-text-with-perl
