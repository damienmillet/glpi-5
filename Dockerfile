FROM alpine:latest

ENV TIMEZONE Europe/Paris

RUN apk update && apk upgrade
RUN apk add apache2 mariadb mariadb-client openrc  icu-data-full

#RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && apk update

# get php from specific repo (community)
RUN apk add php php-apache2 php-fpm php-opcache php-cli php-phar php-zlib \
    php-zip php-bz2 php-ctype php-curl php-pdo_mysql \
    php-mysqli php-json php-xml php-dom php-iconv \
    php-session php-intl php-gd php-mbstring \
    php-opcache php-tokenizer php-simplexml \
    php-fileinfo php-ldap php-exif php-sodium

# RUN ln -s /usr/bin/php /usr/bin/php

ENV PHP_VERSION $(apk info | grep php | grep -E '^php\d.$')

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    mkdir -p /run/apache2 && chown -R apache:apache /run/apache2 /var/www/localhost/htdocs/ && \
    sed -i 's#\#LoadModule rewrite_module modules\/mod_rewrite.so#LoadModule rewrite_module modules\/mod_rewrite.so#' /etc/apache2/httpd.conf && \
    sed -i 's#ServerName www.example.com:80#\nServerName localhost:80#' /etc/apache2/httpd.conf && \
    sed -i 's/skip-networking/\#skip-networking/i' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a log_error = \/var\/lib\/mysql\/error.log' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a skip-external-locking' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a general_log = ON' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a general_log_file = \/var\/lib\/mysql\/query.log' /etc/my.cnf.d/mariadb-server.cnf

#RUN sed -i 's#display_errors = Off#display_errors = On#' /etc/$PHP_VERSION/php.ini && \
#    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 100M#' /etc/$PHP_VERSION/php.ini && \
#    sed -i 's#post_max_size = 8M#post_max_size = 100M#' /etc/$PHP_VERSION/php.ini && \
#    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/$PHP_VERSION/php.ini && \
#    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/$PHP_VERSION/php.ini

WORKDIR /var/www/localhost/htdocs/

ADD scripts/glpi-install.sh /root/glpi-install.sh
ADD scripts/glpidb.sql /root/glpidb.sql
RUN chmod +x /root/glpi-install.sh

EXPOSE 80
EXPOSE 3306
