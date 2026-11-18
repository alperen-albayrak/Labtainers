#!/bin/bash
#
# Runs once after the container is parameterized.
# $1 = container user password, $2 = user id.
#
# The tap shares the host network namespace so it can see every lab bridge.
# Start the span/mirror client, which copies the traffic of each tapped LAN
# to the sensor (monitor_tap:1929).  It waits on its own for the net map and
# the sensor, so it is safe to launch it in the background here.
#
echo "$1" | sudo -S bash -c 'nohup /bin/start_labdump.sh >/var/log/start_labdump.boot 2>&1 &'
exit 0
