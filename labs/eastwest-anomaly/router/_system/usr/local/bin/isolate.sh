#!/bin/bash
# Isolate (or restore) a host by dropping all of its forwarded traffic.
#   isolate.sh <ip>        cut the host off
#   isolate.sh -u <ip>     restore the host
IPT=iptables
$IPT -S >/dev/null 2>&1 || IPT=iptables-nft
if [ "$1" = "-u" ]; then
    $IPT -D FORWARD -s "$2" -j DROP 2>/dev/null
    $IPT -D FORWARD -d "$2" -j DROP 2>/dev/null
    echo "restored $2"
else
    $IPT -I FORWARD 1 -s "$1" -j DROP
    $IPT -I FORWARD 1 -d "$1" -j DROP
    echo "isolated $1"
fi
