#!/bin/bash

chown -R service:service /var/www/html/redmine

if [ ! -f /var/www/html/redmine/config/init_db.lock ]; then
    su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake db:migrate' service
    rm -f /var/www/html/redmine/Gemfile.local
    touch /var/www/html/redmine/config/init_db.lock
fi

if [ ! -f /var/www/html/redmine/config/init_secret.lock ]; then
    echo 'export SECRET_KEY_BASE='$(su -c 'source ~/.bash_profile && cd /var/www/html/redmine && bundle exec rake secret RAILS_ENV=production' service) >> /home/service/.bash_profile
    touch /var/www/html/redmine/config/init_secret.lock
fi
