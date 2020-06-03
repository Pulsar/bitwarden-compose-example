#!/bin/bash

# Setup

GROUPNAME=$BW_GROUP
USERNAME=$BW_USER


# The rest...

# Create default.conf from template
envsubst '${BW_HOST}, ${BW_TLS_PATH}' < /home/bitwarden/default.tmpl > /etc/nginx/conf.d/default.conf


mkdir -p /var/run/nginx
touch /var/run/nginx/nginx.pid
chown -R $USERNAME:$GROUPNAME /var/run/nginx
chown -R $USERNAME:$GROUPNAME /var/cache/nginx
chown -R $USERNAME:$GROUPNAME /var/log/nginx

# Launch a loop to rotate nginx logs on a daily basis
gosu $USERNAME:$GROUPNAME /bin/sh -c "/logrotate.sh loop >/dev/null 2>&1 &"

exec gosu $USERNAME:$GROUPNAME nginx -g 'daemon off;'
