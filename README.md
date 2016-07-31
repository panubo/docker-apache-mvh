# Apache Mass Virtual Host

[![Docker Repository on Quay.io](https://quay.io/repository/panubo/apache-mvh/status "Docker Repository on Quay.io")](https://quay.io/repository/panubo/apache-mvh)

Apache Mass Virtual Host for PHP and static HTML websites.

## Features

- Uses [debian](https://hub.docker.com/_/debian/) base image
- Thin Container. Uses linked [MariaDB](https://hub.docker.com/_/mariadb/) and [SMTP](https://hub.docker.com/r/panubo/postfix/) containers for those services
- Mod PHP5 enabled 
- Both "www" and "naked" domains are served from  from /srv/www/sitename`

## Environment variables

SMTP Setting:

- `SMTP_PORT`
- `SMTP_HOST`

Apache MPM Tuning:

- `MPM_START` - Optional: Default '5'
- `MPM_MINSPARE` - Optional: Default '5'
- `MPM_MAXSPARE` - Optional: Default '10'
- `MPM_MAXWORKERS` - Optional: Default '150'
- `MPM_MAXCONNECTIONS` - Optional: Default '0'

## Status

Production ready.
