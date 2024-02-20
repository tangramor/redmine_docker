#!/bin/bash

chown -R service:service /var/www/html/redmine

if [ "$LOCALE" != "" -a ! -f /var/www/html/redmine/config/init_locale.lock ]; then
    localedef -c -f UTF-8 -i ${LOCALE:0:5} $LOCALE

    sed -i "s/en_US.UTF-8/$LOCALE/g" /etc/locale.conf
    echo 'LC_ALL="'$LOCALE'"' >> /etc/locale.conf
    echo 'LANGUAGE="'$LOCALE'"' >> /etc/locale.conf
    echo 'LC_CTYPE="'$LOCALE'"' >> /etc/locale.conf

    echo 'export LC_ALL="'$LOCALE'"' >> /etc/profile
    echo 'export LANG="'$LOCALE'"' >> /etc/profile

    echo 'source /etc/profile' >> /home/service/.bashrc
    echo 'source /etc/profile' >> /root/.bashrc

    touch /var/www/html/redmine/config/init_locale.lock
fi

if [ ! -f /var/www/html/redmine/config/init_db.lock ]; then
    su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake db:migrate' service
    rm -f /var/www/html/redmine/Gemfile.local
    touch /var/www/html/redmine/config/init_db.lock
fi

if [ ! -f /var/www/html/redmine/config/init_secret.lock ]; then
    echo 'export SECRET_KEY_BASE='$(su -c 'source ~/.bash_profile && cd /var/www/html/redmine && bundle exec rake secret RAILS_ENV=production' service) >> /home/service/.bash_profile
    #su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake generate_secret_token' service
    touch /var/www/html/redmine/config/init_secret.lock
fi
