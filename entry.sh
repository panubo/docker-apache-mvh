#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

# Apache MPM Tuning
export MPM_START=${MPM_START:-5}
export MPM_MINSPARE=${MPM_MINSPARE:-5}
export MPM_MAXSPARE=${MPM_MAXSPARE:-10}
export MPM_MAXWORKERS=${MPM_MAXWORKERS:-150}
export MPM_MAXCONNECTIONS=${MPM_CONNECTIONS:-0}

# SMTP
export SMTP_HOST=${SMTP_PORT_25_TCP_ADDR:-localhost}
export SMTP_PORT=${SMTP_PORT_25_TCP_PORT:-25}
cat << EOF > /etc/msmtprc
account default
auto_from on

# The SMTP smarthost.
host ${SMTP_HOST}
port ${SMTP_PORT}
EOF

exec $@
