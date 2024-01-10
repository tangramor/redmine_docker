FROM centos:7

USER root

RUN groupadd -g 500 service \
    && useradd -g service -u 500 service \
    && yum install -y epel-release \
    && yum install -y wget subversion sudo bzip2 make which patch autoconf automake bison gcc-c++ libffi-devel libtool patch readline-devel ruby sqlite-devel zlib-devel glibc-headers glibc-devel openssl-devel ImageMagick-devel libcurl-devel mysql-devel git \
    && chmod 740 /etc/sudoers \
    && echo "service    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chmod 440 /etc/sudoers \
    && chmod o+x "/home/service"

USER service

RUN gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && curl -sSL https://get.rvm.io | bash -s stable \
    && source ~/.bashrc \
    && source ~/.bash_profile \
    && echo "ruby_url=https://cache.ruby-china.com/pub/ruby" > ~/.rvm/user/db \
    && rvm install 2.3.8 --disable-binary \
    && rvm use 2.3.8 --default \
    && echo 'export GEM_HOME="$HOME/.rvm/gems/ruby-2.3.8"' >> ~/.bash_profile \
    && echo 'export GEM_PATH="$HOME/.rvm/gems/ruby-2.3.8:$HOME/.rvm/gems/ruby-2.3.8@global"' >> ~/.bash_profile

WORKDIR /var/www/html/redmine

USER root

RUN wget -c -t 0 https://www.redmine.org/releases/redmine-3.3.3.tar.gz \
    && tar zxf redmine-3.3.3.tar.gz \
    && mv redmine-3.3.3/* ./ \
    && rm -rf redmine-3.3.3 redmine-3.3.3.tar.gz \
    && chown -R service:service /var/www/html/redmine \
    && yum remove -y ruby

USER service

COPY Gemfile.lock /var/www/html/redmine/

RUN echo 'export PATH=$PATH:/home/service/.rvm/rubies/ruby-2.3.8/bin:/home/service/.rvm/gems/ruby-2.3.8/bin' >> ~/.bash_profile \
    && source ~/.bashrc \
    && source ~/.bash_profile \
    && ruby -v \
    && gem install bundler -v 2.0.0.pre.3 \
    && rvm repair wrappers \
    && sudo chown service:service Gemfile.lock \
    && bundle config set --local without 'development test' \
    && bundle install \
    #&& bundle exec rake generate_secret_token \
    && gem install mysql2 -v 0.3.21 \
    && gem install passenger -v 6.0.19 \
    && echo 'export SECRET_KEY_BASE='$(bundle exec rake secret RAILS_ENV=production) >> ~/.bash_profile \
    && rvmsudo passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx

COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY start.sh /start.sh

EXPOSE 443 80

USER root
CMD ["/bin/bash", "-c", "/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf;/start.sh;tail -f /opt/nginx/logs/*.log"]
