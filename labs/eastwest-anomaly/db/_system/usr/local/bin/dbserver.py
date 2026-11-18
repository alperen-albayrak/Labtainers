#!/usr/bin/env python3
# Minimal stand-in for a database server.  It listens on TCP 5432 and returns
# the "records" table.  The lab uses it only as an east-west target; it is not
# a real SQL engine.
import socket

TABLE = """\
id | name            | account   | secret
---+-----------------+-----------+------------------
 1 | Acme Ltd        | 100-204   | FLAG{east_west_db_read}
 2 | Globex          | 100-887   | card=4012-xxxx-9931
 3 | Initech         | 100-553   | card=4111-xxxx-7720
(3 rows)
"""

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", 5432))
    s.listen(16)
    while True:
        conn, _ = s.accept()
        try:
            conn.recv(256)          # read the query, ignore its content
            conn.sendall(TABLE.encode())
        except OSError:
            pass
        finally:
            conn.close()

if __name__ == "__main__":
    main()
