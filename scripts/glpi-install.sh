!#/bin/sh
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    apk update && apk add jq
    # get glpi latest
    cd ~/
    wget https://api.github.com/repos/glpi-project/glpi/releases/latest -O latest.json
    jq '.assets' latest.json | jq '.[0].browser_download_url' | xargs wget -O glpi.tgz
    tar zxvf glpi.tgz
    mv glpi /var/www/localhost/htdocs
    chown -R apache:apache /var/www/localhost/htdocs
    # purge
    rm latest.json && rm glpi.tgz
    apk del jq
    # openrc
    openrc
    touch /run/openrc/softlevel
    # apache service
    rc-update add apache2
    rc-service apache2 start
    rc-service apache2 reload
    # mariadb
    /etc/init.d/mariadb setup
    rc-update add mariadb
    rc-service mariadb restart
    mysql -sfu root < "glpidb.sql"
else
    echo "-- Not first container startup --"
fi

rc-service apache2 reload
rc-service mariadb restart
