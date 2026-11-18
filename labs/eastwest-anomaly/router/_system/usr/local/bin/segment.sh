#!/bin/bash
# Apply the fixed baseline network segmentation on the router.
# Uses whichever iptables backend works on the build host (legacy or nft).
IPT=iptables
$IPT -S >/dev/null 2>&1 || IPT=iptables-nft

sysctl -w net.ipv4.ip_forward=1 >/dev/null

$IPT -F FORWARD
$IPT -P FORWARD ACCEPT
$IPT -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -s 10.1.1.13   -d 10.2.3.0/24 -j ACCEPT   # admin -> db ok
$IPT -A FORWARD -s 10.2.2.0/24 -d 10.2.3.0/24 -j ACCEPT   # app   -> db ok
$IPT -A FORWARD -s 10.2.1.0/24 -d 10.2.3.0/24 -j DROP     # web   -> db blocked
$IPT -A FORWARD -s 10.1.1.0/24 -d 10.2.3.0/24 -j DROP     # other users -> db blocked
echo "baseline segmentation applied with $IPT"
