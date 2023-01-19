FROM alpine:latest

ENV TIMEZONE Europe/Paris

RUN apk update && apk upgrade
RUN apk add apache2 php82 php82-apache2 mariadb mariadb-client openrc \
    php82-fpm php82-opcache php82-cli php82-phar php82-zlib \
    php82-zip php82-bz2 php82-ctype php82-curl php82-pdo_mysql \
    php82-mysqli php82-json php82-xml php82-dom php82-iconv \
    php82-xdebug php82-session php82-intl php82-gd php82-mbstring \
    php82-apcu php82-opcache php82-tokenizer php82-simplexml \
    php82-fileinfo php82-ldap php82-exif php82-sodium

RUN ln -s /usr/bin/php8 /usr/bin/php

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

RUN sed -i 's#display_errors = Off#display_errors = On#' /etc/php82/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 100M#' /etc/php82/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 100M#' /etc/php82/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php82/php.ini && \
    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/php82/php.ini

WORKDIR /var/www/localhost/htdocs/

ADD scripts/glpi-install.sh /root/glpi-install.sh
ADD scripts/glpidb.sql /root/glpidb.sql
RUN chmod +x /root/glpi-install.sh

EXPOSE 80
EXPOSE 3306
