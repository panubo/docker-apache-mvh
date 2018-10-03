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
export SMTP_HOST=${SMTP_PORT_25_TCP_ADDR-${SMTP_HOST:-'localhost'}}
export SMTP_PORT=${SMTP_PORT_25_TCP_PORT-${SMTP_PORT:-'25'}}
cat << EOF > /etc/msmtprc
account default
auto_from on

# The SMTP smarthost.
host ${SMTP_HOST}
port ${SMTP_PORT}
EOF

# Mountfile Support

# LICENSE: MIT License, Copyright (c) 2017-2018 Volt Grid Pty Ltd t/a Panubo
# See: https://github.com/panubo/bash-container
# run_mountfile [FILENAME] [DATADIR]
# run_mountfile Mountfile /srv/remote
run_mountfile() {
  # Mount all dirs specified in Mountfile
  local mountfile="${1:-'Mountfile'}"
  local data="${2:-'/srv/remote'}"
  local mount_uid="48"
  local mount_gid="48"
  local remote_dir=""
  local mount_dir=""
  local root_dir=""

  if [[ ! -e "${mountfile}" ]]; then echo "Mountfile not found"; return 0; fi
  if [[ ! -e "${data}" ]]; then echo "Datadir not found"; return 1; fi

  # make sure we are operating in the same dir that holds the mountfile
  root_dir="$(dirname "$(readlink -f "${mountfile}")")"
  pushd "${root_dir}" 1> /dev/null || exit 1

  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    [[ "${line}" =~ ([[:alnum:]/\.]*)[[:space:]]?:[[:space:]]?(.*) ]]
    remote_dir="${BASH_REMATCH[1]}"
    mount_dir="${BASH_REMATCH[2]}"
    (>&1 echo "Mounting remote path ${remote_dir} => ${mount_dir}")

    # create ephemeral or remote dir if not exist
    if [[ "${remote_dir}" == "ephemeral" ]]; then
      remote_dir="$(mktemp -d)"
    else
      [[ ! -e "${data}/${remote_dir}" ]] && mkdir -p "${data}/${remote_dir}"
      remote_dir="${data}/${remote_dir}"
    fi

    # remove if mount_dir is a ink
    [[ -L "${mount_dir}" ]] && rm -f "${mount_dir}"

    # create mount dir (including parents) if required
    mkdir -p "${mount_dir}"

    # Copy mount to remote, if remote is empty, and mount_dir has files
    if [[ "$(ls -A "${mount_dir}")" ]] && [ ! "$(ls -A "${remote_dir}")" ]; then
      cp -a "${mount_dir}/" "${remote_dir}"
      # Fix permissions recursively in remote
      chown -R ${mount_uid}:${mount_gid} "$remote_dir"
    else
      # Set permission on remote
      chown ${mount_uid}:${mount_gid} "$remote_dir"
    fi

    # Delete mount_dir if exists Create symlink to remote_dir
    [[ -e "${mount_dir}" ]] && rm -rf "${mount_dir}"
    ln -snf "$remote_dir" "$mount_dir"

  done < "${mountfile}"
}

if [ "${PROCESS_MOUNTFILES}" == "true" ]; then
  : "${REMOTE_BASE:=/srv/remote}"
  MOUNTFILES=$(find /srv/www -maxdepth 2 -mindepth 2 -type f -name 'Mountfile')
  for MOUNTFILE in ${MOUNTFILES}; do
    SITE="$(basename $(dirname $MOUNTFILE))"
    echo ">> Processing $SITE"
    mkdir -p "${REMOTE_BASE}/${SITE}"
    run_mountfile ${MOUNTFILE} "${REMOTE_BASE}/${SITE}"
  done
fi

exec $@
