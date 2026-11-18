#!/usr/bin/env python3
# Simple TCP connect scanner used from the compromised web server to discover
# reachable services on the other tiers.
#   scan.py <host> [host...]
import socket, sys

PORTS = [22, 80, 443, 3306, 5432, 8080]

def scan(host):
    print("scanning %s" % host)
    for p in PORTS:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1.0)
        try:
            s.connect((host, p))
            print("  %5d open" % p)
        except (socket.timeout, ConnectionRefusedError, OSError):
            pass
        finally:
            s.close()

if __name__ == "__main__":
    hosts = sys.argv[1:] or ["10.2.2.11", "10.2.3.11"]
    for h in hosts:
        scan(h)
