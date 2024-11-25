#!/bin/bash

chown -R service:service /var/www/html/redmine

if [ ! -f /var/www/html/redmine/config/init_secret.lock ]; then
    su -c 'source ~/.bash_profile && cd /var/www/html/redmine && bundle exec rake generate_secret_token RAILS_ENV=production' service
    echo 'export SECRET_KEY_BASE='$(grep "secret_key_base" /var/www/html/redmine/config/initializers/secret_token.rb | cut -d "'" -f 2) >> /home/service/.bash_profile
    touch /var/www/html/redmine/config/init_secret.lock
fi

if [ ! -f /var/www/html/redmine/config/init_db.lock ]; then
    yum install -y mysql

    HOST=mysql  # MySQL Host
    USER=root   # MySQL User
    PASSWORD=$MYSQL_ROOT_PASSWORD # MySQL Password
    DB_NAME=mysql # MySQL Database Name

    TIMEOUT=30          # Timeout (seconds)
    WAIT_INTERVAL=3     # Wait time between each check (seconds)

    elapsed_time=0

    while ! mysql -h "$HOST" -u"$USER" -p"$PASSWORD" -e "USE $DB_NAME;" 2>/dev/null; do
        if [ $elapsed_time -ge $TIMEOUT ]; then
            echo "Error: Cannot connect to MySQL server {$HOST}，exceeds ${TIMEOUT} seconds limit"
            exit 1
        fi

        echo "Connection failed, wait ${WAIT_INTERVAL} seconds to retry..."
        sleep $WAIT_INTERVAL
        elapsed_time=$((elapsed_time + WAIT_INTERVAL))
    done

    su -c 'source ~/.bash_profile && cd /var/www/html/redmine && RAILS_ENV=production bundle exec rake db:migrate' service
    rm -f /var/www/html/redmine/Gemfile.local
    touch /var/www/html/redmine/config/init_db.lock
    
    yum remove -y mysql
fi