FROM debian:bullseye

EXPOSE 80

# updated to match debian www-user
ENV MOUNTFILE_MOUNT_UID=33 MOUNTFILE_MOUNT_GID=33

# Install Requirements
RUN apt-get update \
  && apt-get install -y ca-certificates msmtp \
  && apt-get install -y libapache2-mod-php7.4 php7.4 php7.4-gd php-pear php7.4-mysql php7.4-pgsql php7.4-sqlite php7.4-intl php7.4-ldap \
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
  && a2enmod vhost_alias mpm_prefork deflate rewrite expires headers php7.4 \
  && a2ensite mvhost.conf \
  && sed -i -e 's@^;sendmail_path =.*@sendmail_path = /usr/bin/msmtp -t -i@g' /etc/php/7.4/apache2/php.ini /etc/php/7.4/cli/php.ini \
  && sed -i -e 's@short_open_tag =.*@short_open_tag = On@g' /etc/php/7.4/apache2/php.ini /etc/php/7.4/cli/php.ini \
  && sed -i -e 's@post_max_size =.*@post_max_size = 32M@g' /etc/php/7.4/apache2/php.ini /etc/php/7.4/cli/php.ini \
  && sed -i -e 's@upload_max_filesize =.*@upload_max_filesize = 32M@g' /etc/php/7.4/apache2/php.ini /etc/php/7.4/cli/php.ini \
  && mkdir -p /srv/www

ADD entry.sh /
ENTRYPOINT ["/entry.sh"]
CMD [ "/usr/sbin/apache2ctl", "-D", "FOREGROUND", "-k", "start" ]
