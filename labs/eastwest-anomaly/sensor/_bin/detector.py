#!/usr/bin/env python3
"""East-west anomaly detector.

Reads the per-LAN captures that the hidden tap mirrors to this sensor
(/taps/*.pcap), reconstructs TCP connection attempts (SYN packets) and raises
two behaviour alerts:

  SCAN            one internal host opens connections to many different
                  destination host:port pairs in a short time.
  NEW_ADMIN_SSH   an SSH connection to a server comes from a host other than
                  the IT admin workstation (the only host that normally
                  administers servers over SSH).

It inspects connection metadata only (who, to whom, port), never payload.
"""
import glob
import os
import re
import subprocess
import sys
from collections import defaultdict

TAP_DIR = "/taps"
ADMIN_IP = "10.1.1.13"          # the only host that normally SSHes to servers
SCAN_FANOUT = 6                 # distinct dst:port from one src -> scan

LINE = re.compile(
    r"^(?P<ts>\d+\.\d+)\s+IP\s+(?P<src>\d+\.\d+\.\d+\.\d+)\.(?P<sport>\d+)\s+>\s+"
    r"(?P<dst>\d+\.\d+\.\d+\.\d+)\.(?P<dport>\d+):"
)


def read_syns(pcap):
    """Yield (ts, src, dst, dport) for every SYN-only packet in a capture."""
    cmd = ["tcpdump", "-nn", "-tt", "-r", pcap,
           "tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack == 0"]
    try:
        out = subprocess.run(cmd, stdout=subprocess.PIPE,
                             stderr=subprocess.DEVNULL, text=True).stdout
    except FileNotFoundError:
        sys.exit("tcpdump not found")
    for line in out.splitlines():
        m = LINE.match(line)
        if m:
            yield (float(m["ts"]), m["src"], m["dst"], int(m["dport"]))


def collect():
    syns = []
    for pcap in sorted(glob.glob(os.path.join(TAP_DIR, "*.pcap"))):
        syns.extend(read_syns(pcap))
    return syns


def detect_scan(syns):
    targets = defaultdict(set)
    for _, src, dst, dport in syns:
        targets[src].add((dst, dport))
    alerts = []
    for src, pairs in targets.items():
        if len(pairs) >= SCAN_FANOUT:
            alerts.append((src, sorted(pairs)))
    return alerts


def detect_admin_ssh(syns):
    alerts = []
    seen = set()
    for _, src, dst, dport in syns:
        if dport == 22 and src != ADMIN_IP and (src, dst) not in seen:
            seen.add((src, dst))
            alerts.append((src, dst))
    return alerts


def main():
    syns = collect()
    print("east-west detector: %d connection attempts seen across %s" %
          (len(syns), TAP_DIR))
    n = 0

    for src, pairs in detect_scan(syns):
        n += 1
        print("\n[ALERT] SCAN  source=%s  touched %d host:port pairs" %
              (src, len(pairs)))
        for dst, dport in pairs:
            print("        -> %s:%d" % (dst, dport))

    for src, dst in detect_admin_ssh(syns):
        n += 1
        print("\n[ALERT] NEW_ADMIN_SSH  %s -> %s:22  "
              "(SSH to a server from a non-admin host)" % (src, dst))

    if n == 0:
        print("\nno anomalies")
    else:
        print("\n%d alert(s)" % n)
    return 0


if __name__ == "__main__":
    sys.exit(main())
