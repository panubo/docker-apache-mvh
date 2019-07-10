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

# LICENSE: MIT License, Copyright (c) 2017-2019 Volt Grid Pty Ltd t/a Panubo
# See: https://github.com/panubo/bash-container
# run_mountfile [FILENAME] [DATADIR]
# run_mountfile Mountfile /srv/remote
run_mountfile() {
  # Mount all dirs specified in Mountfile
  local mountfile="${1:-"Mountfile"}"
  local data_dir="${2:-"/srv/remote"}"
  local mount_uid="33"
  local mount_gid="33"
  local source_dir=""
  local target_dir=""
  local working_dir=""

  if [[ $EUID -ne 0 ]]; then echo "Must be run as root"; return 1; fi
  if [[ ! -e "${mountfile}" ]]; then echo "Mountfile not found"; return 0; fi
  if [[ ! -e "${data_dir}" ]]; then echo "Data dir not found"; return 1; fi

  # normalise path to Mountfile
  mountfile="$(realpath "${mountfile}")"

  # normalise data dir
  data_dir="$(realpath "${data_dir}")"

  # calculate working_dir from Mountfile location
  working_dir="$(dirname "${mountfile}")"

  # make sure we are operating in the same dir that holds the Mountfile
  pushd "${working_dir}" 1> /dev/null || return 1

  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    [[ "${line}" =~ ([[:alnum:]/\.-]*)[[:space:]]?:[[:space:]]?(.*) ]]
    s="${BASH_REMATCH[1]}"
    t="${BASH_REMATCH[2]}"

    # normalise
    # remove link if it exists otherwise readlink will follow link to remote
    [[ -L "${working_dir}/${t}" ]] && rm -f "${working_dir}/${t}"
    target_dir="$(cd "${working_dir}" && readlink -f -m "${t}")"

    # handle ephemeral
    if [[ "${s}" == "ephemeral" ]]; then
      # create ephemeral
      source_dir="$(mktemp -d)"
    else
      # normalise
      source_dir="$(cd "${data_dir}" && readlink -f -m "${s}")"
      # safety checks
      [[ ! "${target_dir}" =~ ${working_dir} ]] && { echo "Error: Target outside working directory!" && return 129; }
      [[ ! "${source_dir}" =~ ${data_dir} ]] && { echo "Error: Source not within data directory!" && return 129; }
    fi

    # make remote source dir if not exist
    [[ ! -e "${source_dir}" ]] && mkdir -p "${source_dir}"

    # create mount target (including parents) if required
    mkdir -p "${target_dir}"

    # Copy mount to remote, if remote is empty, and target_dir has files
    if [[ "$(ls -A "${target_dir}")" ]] && [[ ! "$(ls -A "${source_dir}")" ]]; then
      echo "Copying template content ${target_dir} => ${source_dir}"
      # gnu cp does not respect trainling / with -a, so we remove the dir
      rmdir "${source_dir}"
      cp -a "${target_dir}/" "${source_dir}"
      # Fix permissions recursively in remote
      chown -R ${mount_uid}:${mount_gid} "${source_dir}"
    else
      # Set permission on remote
      chown ${mount_uid}:${mount_gid} "${source_dir}"
    fi

    (>&1 echo "Mounting remote path ${source_dir} => ${target_dir}")

    # Delete target_dir if exists. Create symlink to source_dir
    [[ -e "${target_dir}" ]] && rm -rf "${target_dir}"
    ln -snf "${source_dir}" "${target_dir}"

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
