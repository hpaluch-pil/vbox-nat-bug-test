# Demo of VirtualBox NAT/SLIRP bug

There is a bug when using VirtualBox "NAT" interface (but NOT "NAT Network") with any
king of guest (Linux, Windows,...) and Windows Host.

After few tries NAT/SLIRP will remove 1st byte of response and truncate data to be 1 byte less.
- expected data: "ABCDEFGH"
- received data  "BCDEFGH"

How to reproduce:
- run `./tcp_service.pl` on Linux remote machine
- run `./tcp_client.pl SERVER_IP 9999` in VirtualBox Guest (Linux preferred) using "NAT" Interface.

After a while incorrect responded should be received...

# Cause

SLIRP Layer (that provides user-space TCP UDP emulation and NAT using BSD libalias) closes remote
connection before received data are correctly processed. Solution is to skip socket
close until socket data are properly processed as Established.

Patch: pending


