#!/bin/bash
# database tier: run the records service on TCP 5432.
# $1 = user password.
echo "$1" | sudo -S systemctl enable --now dbserver.service
exit 0
