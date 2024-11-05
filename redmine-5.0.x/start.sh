#!/bin/bash

chown -R service:service /var/www/html/redmine

if [ ! -f /var/www/html/redmine/config/init_db.lock ]; then
    yum install -y mysql

    HOST=mysql    # MySQL 主机
    USER=root # MySQL 用户名
    PASSWORD=$MYSQL_ROOT_PASSWORD # MySQL 密码
    DB_NAME=mysql # 数据库名（可以选择性使用）

    TIMEOUT=30          # 超时时间（秒）
    WAIT_INTERVAL=3     # 每次检查的间隔（秒）

    elapsed_time=0

    while ! mysql -h "$HOST" -u"$USER" -p"$PASSWORD" -e "USE $DB_NAME;" 2>/dev/null; do
        if [ $elapsed_time -ge $TIMEOUT ]; then
            echo "错误：无法连接到 MySQL {$HOST}，已超过 ${TIMEOUT} 秒超时限制。"
            exit 1
        fi

        echo "连接失败，等待 ${WAIT_INTERVAL} 秒后重试..."
        sleep $WAIT_INTERVAL
        elapsed_time=$((elapsed_time + WAIT_INTERVAL))
    done

    su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake db:migrate' service
    rm -f /var/www/html/redmine/Gemfile.local
    touch /var/www/html/redmine/config/init_db.lock
    
    yum remove -y mysql
fi

if [ ! -f /var/www/html/redmine/config/init_secret.lock ]; then
    echo 'export SECRET_KEY_BASE='$(su -c 'source ~/.bash_profile && cd /var/www/html/redmine && bundle exec rake secret RAILS_ENV=production' service) >> /home/service/.bash_profile
    #su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake generate_secret_token' service
    touch /var/www/html/redmine/config/init_secret.lock
fi
