#!/bin/bash

chown -R service:service /var/www/html/redmine

if [ ! -f /var/www/html/redmine/init_db.lock ]; then
    su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake db:migrate' service
    touch /var/www/html/redmine/init_db.lock
fi

if [ ! -f /var/www/html/redmine/config/secret_token.rb ]; then
    su -c 'source ~/.bash_profile && RAILS_ENV=production bundle exec rake generate_secret_token' service
fi
