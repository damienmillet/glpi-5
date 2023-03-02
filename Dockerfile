FROM alpine:latest

ENV TIMEZONE Europe/Paris

RUN apk update && apk upgrade
RUN apk add apache2 mariadb mariadb-client openrc  icu-data-full

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && apk update

# get php from specific repo (community)
RUN apk add php@community php-apache2@community php-fpm@community php-opcache@community php-cli@community php-phar@community php-zlib@community \
    php-zip@community php-bz2@community php-ctype@community php-curl@community php-pdo_mysql@community \
    php-mysqli@community php-json@community php-xml@community php-dom@community php-iconv@community \
    php-session@community php-intl@community php-gd@community php-mbstring@community \
    php-opcache@community php-tokenizer@community php-simplexml@community \
    php-fileinfo@community php-ldap@community php-exif@community php-sodium@community

# RUN ln -s /usr/bin/php /usr/bin/php

ENV PHP_VERSION $(apk info | grep php | grep -E '^php\d.$')

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    mkdir -p /run/apache2 && chown -R apache:apache /run/apache2 && chown -R apache:apache /var/www/localhost/htdocs/ && \
    sed -i 's#\#LoadModule rewrite_module modules\/mod_rewrite.so#LoadModule rewrite_module modules\/mod_rewrite.so#' /etc/apache2/httpd.conf && \
    sed -i 's#ServerName www.example.com:80#\nServerName localhost:80#' /etc/apache2/httpd.conf && \
    sed -i 's/skip-networking/\#skip-networking/i' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a log_error = \/var\/lib\/mysql\/error.log' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a skip-external-locking' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a general_log = ON' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a general_log_file = \/var\/lib\/mysql\/query.log' /etc/my.cnf.d/mariadb-server.cnf

RUN sed -i 's#display_errors = Off#display_errors = On#' /etc/php/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 100M#' /etc/php/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 100M#' /etc/php/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php/php.ini && \
    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/php/php.ini

WORKDIR /var/www/localhost/htdocs/

ADD scripts/glpi-install.sh /root/glpi-install.sh
ADD scripts/glpidb.sql /root/glpidb.sql
RUN chmod +x /root/glpi-install.sh

EXPOSE 80
EXPOSE 3306
