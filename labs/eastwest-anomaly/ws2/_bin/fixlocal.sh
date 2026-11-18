#!/bin/bash
# ws2: victim workstation.  Runs SSH and holds a confidential file.
# $1 = user password.
PW="$1"
run(){ echo "$PW" | sudo -S bash -c "$1"; }
run "sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
run "systemctl enable --now labssh.service"
# a local account with a weak password (used by the user-to-user scenario)
run "id staff >/dev/null 2>&1 || useradd -m -s /bin/bash staff"
run "echo 'staff:Autumn2024' | chpasswd"
cp "$HOME/secret.txt" "$HOME/secret.txt" 2>/dev/null
exit 0
