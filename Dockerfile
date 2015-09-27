FROM debian:jessie

MAINTAINER Andrew Cutler <andrew@panubo.com>

EXPOSE 80

# Install Requirements
RUN apt-get update && \
    apt-get install -y apache2-mpm-prefork ca-certificates && \
    apt-get install -y libapache2-mod-php5 php5 php-pear php5-mysql php5-pgsql php5-sqlite php5-mcrypt php5-intl php5-ldap && \
    # Install Pear Requirements
    pear install mail_mime mail_mimedecode net_smtp net_idna2-beta auth_sasl net_sieve crypt_gpg && \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# Host Configuration
COPY apache2.conf /etc/apache2/apache2.conf
COPY mpm_prefork.conf /etc/apache2/mods-available/
COPY vhost.conf /etc/apache2/sites-available/
RUN rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/* && \
    a2enmod vhost_alias mpm_prefork deflate rewrite expires headers php5 && \
    a2ensite vhost.conf && \
    mkdir -p /srv/www

ADD entry.sh /
ENTRYPOINT ["/entry.sh"]
CMD [ "/usr/sbin/apache2ctl", "-D", "FOREGROUND", "-k", "start" ]
