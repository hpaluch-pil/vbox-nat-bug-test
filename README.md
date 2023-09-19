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

experimental patch is under [vbox-patches/close-fix-slirp.c.patch](vbox-patches/close-fix-slirp.c.patch])


