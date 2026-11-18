# eastwest-anomaly

East-west (internal) traffic anomaly detection lab for CENG519 Network Security
(METU, 2026-27 Fall).

An office LAN (user workstations + IT admin) and a three-tier server side
(web / app / db) sit behind one router. A hidden tap mirrors every internal LAN
to a sensor that reconstructs connection flows and raises anomaly alerts. The
lab shows an attacker moving sideways between servers, how the sensor detects it
from connection metadata alone, and how isolating the compromised host stops it.

## Containers
- `ws1`, `ws2`, `admin` — office LAN (10.1.1.0/24)
- `web` — web tier (10.2.1.0/24), compromised foothold
- `app` — app tier (10.2.2.0/24), SSH + database client
- `db`  — database tier (10.2.3.0/24), holds the records table
- `router` — forwards between the LANs, applies baseline segmentation
- `sensor` — receives the mirrored traffic and runs the detector
- `tap` — hidden span port (mirrors all internal LANs to the sensor)

## Build and run
    rebuild eastwest-anomaly

## Server-to-server scenario (from web)
    attack.sh                 # discovery -> password spray -> pivot to db

## Detection (from sensor)
    detector.py               # raises SCAN and NEW_ADMIN_SSH

## Defense (from router)
    isolate.sh 10.2.1.11      # isolate the compromised web host
    isolate.sh -u 10.2.1.11   # restore it
