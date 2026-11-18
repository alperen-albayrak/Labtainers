#!/bin/bash
# app server (application tier): reachable by SSH (normally only from the IT
# admin) and allowed to talk to the database tier.
# $1 = user password.
PW="$1"
run(){ echo "$PW" | sudo -S bash -c "$1"; }

run "sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
run "sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
run "systemctl enable --now labssh.service"

# service account the nightly backup job uses (weak password)
run "id appsvc >/dev/null 2>&1 || useradd -m -s /bin/bash appsvc"
run "echo 'appsvc:Summer2024' | chpasswd"

run "cat > /usr/local/bin/getdata.sh <<'SH'
#!/bin/bash
DB=\${1:-db}
exec 3<>/dev/tcp/\$DB/5432
echo 'SELECT * FROM records;' >&3
cat <&3
exec 3<&-
SH
chmod 755 /usr/local/bin/getdata.sh"
exit 0
