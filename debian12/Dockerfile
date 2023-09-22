FROM debian:bookworm

EXPOSE 80

# updated to match debian www-user
ENV MOUNTFILE_MOUNT_UID=33 MOUNTFILE_MOUNT_GID=33

# Install Requirements
RUN apt-get update \
  && apt-get install -y ca-certificates msmtp \
  && apt-get install -y libapache2-mod-php8.2 php8.2 php8.2-gd php-pear php8.2-mysql php8.2-pgsql php8.2-sqlite php8.2-intl php8.2-ldap \
  && apt-get install -y vim wget \
  # Install Pear Requirements
  && pear install mail_mime mail_mimedecode net_smtp net_idna2-beta auth_sasl net_sieve crypt_gpg \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* /tmp/*

# Install PHP Extras
RUN cd /tmp \
  && wget https://github.com/panubo/php-extras/archive/master.tar.gz \
  && tar --wildcards -C /usr/share/php/ -xvf master.tar.gz --strip 1 '*.php'  \
  && rm -f /tmp/master.tar.gz

# Host Configuration
COPY apache2.conf /etc/apache2/apache2.conf
COPY mpm_prefork.conf /etc/apache2/mods-available/
COPY mvhost.conf /etc/apache2/sites-available/
RUN rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/* \
  && a2enmod vhost_alias mpm_prefork deflate rewrite expires headers php8.2 \
  && a2ensite mvhost.conf \
  && sed -i -e 's@^;sendmail_path =.*@sendmail_path = /usr/bin/msmtp -t -i@g' /etc/php/8.2/apache2/php.ini /etc/php/8.2/cli/php.ini \
  && sed -i -e 's@short_open_tag =.*@short_open_tag = On@g' /etc/php/8.2/apache2/php.ini /etc/php/8.2/cli/php.ini \
  && sed -i -e 's@post_max_size =.*@post_max_size = 32M@g' /etc/php/8.2/apache2/php.ini /etc/php/8.2/cli/php.ini \
  && sed -i -e 's@upload_max_filesize =.*@upload_max_filesize = 32M@g' /etc/php/8.2/apache2/php.ini /etc/php/8.2/cli/php.ini \
  && mkdir -p /srv/www

ADD entry.sh /
ENTRYPOINT ["/entry.sh"]
CMD [ "/usr/sbin/apache2ctl", "-D", "FOREGROUND", "-k", "start" ]
