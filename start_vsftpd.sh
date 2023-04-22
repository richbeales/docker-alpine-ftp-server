#!/bin/bash

# Remove all ftp users
grep '/ftp/' /etc/passwd | cut -d':' -f1 | xargs -n1 deluser

# Create users
# USERS='name1|password1|[folder1][|uid1] name2|password2|[folder2][|uid2]'
# e.g.
# user|password foo|bar|/home/foo
# OR
# user|password|/home/user/dir|10000
# OR
# user|password||10000

# Default user 'ftp' with password 'alpineftp'

USERS="${USERS:-ftp|alpineftp}"

IFS=" "
for i in $USERS; do
    IFS="|" read -r NAME PASS FOLDER UID <<< "${i}"

    FOLDER="${FOLDER:-/ftp/$NAME}"

    UID_OPT=""
    if [ -n "$UID" ]; then
        UID_OPT="-u $UID"
    fi

    echo -e "$PASS\n$PASS" | adduser -h "$FOLDER" -s /sbin/nologin $UID_OPT "$NAME"
    mkdir -p "$FOLDER"
    chown "$NAME:$NAME" "$FOLDER"
done

MIN_PORT="${MIN_PORT:-21000}"
MAX_PORT="${MAX_PORT:-21010}"

ADDR_OPT=""
if [ -n "$ADDRESS" ]; then
    ADDR_OPT="-opasv_address=$ADDRESS"
fi

# Used to run custom commands inside container
if [ -n "$1" ]; then
    exec "$@"
else
    exec /usr/sbin/vsftpd -opasv_min_port="$MIN_PORT" -opasv_max_port="$MAX_PORT" $ADDR_OPT /etc/vsftpd/vsftpd.conf
fi
