#!/bin/bash
# router: enable the baseline segmentation service (re-applies on every start).
# $1 = user password.
echo "$1" | sudo -S systemctl enable --now labseg.service
exit 0
