FROM almalinux:9

LABEL org.opencontainers.image.authors="Wang Junhua(tangramor@gmail.com)"
LABEL org.opencontainers.image.url="https://www.github.com/tangramor/redmine_docker"

USER root

RUN groupadd -g 500 service \
    && useradd -g service -u 500 service \
    && yum install -y epel-release \
    && yum install -y wget subversion sudo bzip2 make \
        which patch autoconf automake bison gcc-c++ \
        libffi-devel libtool patch readline-devel ruby \
        sqlite-devel zlib-devel glibc-headers \
        glibc-devel openssl-devel ImageMagick-devel \
        libcurl-devel git procps ghostscript unzip \
    && dnf --enablerepo=crb install -y mysql-devel \
    && yum clean all && dnf clean all \
    && chmod 740 /etc/sudoers \
    && echo "service    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chmod 440 /etc/sudoers \
    && chmod o+x "/home/service"

USER service

ARG RUBY_MIRROR=""
ARG GEM_MIRROR=""

ENV RUBY_VERSION=3.1.6
ENV REDMINE_VERSION=5.0.10
ENV BUNDLE_VERSION=2.5.22
ENV GEM_PASSENGER_VERSION=6.0.22

RUN gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles \
    && source ~/.bashrc \
    && source ~/.bash_profile \
    && if [ "$RUBY_MIRROR" != "" ]; then echo 'ruby_url='${RUBY_MIRROR} > ~/.rvm/user/db; fi \
    && rvm install ${RUBY_VERSION} --disable-binary \
    && rvm use ${RUBY_VERSION} --default \
    && echo 'export GEM_HOME="$HOME/.rvm/gems/ruby-'${RUBY_VERSION}'"' >> ~/.bash_profile \
    && echo 'export GEM_PATH="$HOME/.rvm/gems/ruby-'${RUBY_VERSION}':$HOME/.rvm/gems/ruby-'${RUBY_VERSION}'@global"' >> ~/.bash_profile

WORKDIR /var/www/html/redmine

USER root

RUN wget -c -t 0 https://www.redmine.org/releases/redmine-${REDMINE_VERSION}.tar.gz \
    && tar zxf redmine-${REDMINE_VERSION}.tar.gz \
    && mv redmine-${REDMINE_VERSION}/* ./ \
    && rm -rf redmine-${REDMINE_VERSION} redmine-${REDMINE_VERSION}.tar.gz \
    && chown -R service:service /var/www/html/redmine \
    && yum remove -y ruby

USER service

COPY Gemfile.local /var/www/html/redmine/

ENV RAILS_ENV=production

RUN sed -i "s/ruby .*$/ruby '"${RUBY_VERSION}"'/" Gemfile \
    && echo 'export RUBY_VERSION='${RUBY_VERSION} >> ~/.bash_profile \
    && echo 'export PATH=/home/service/.rvm/gems/ruby-'${RUBY_VERSION}'/bin:$PATH:/home/service/.rvm/rubies/ruby-'${RUBY_VERSION}'/bin' >> ~/.bash_profile \
    && source ~/.bashrc \
    && source ~/.bash_profile \
    && ruby -v \
    && gem install bundler -v ${BUNDLE_VERSION} \
    && rvm repair wrappers \
    && sudo chown service:service Gemfile.local \
    && if [ "$GEM_MIRROR" != "" ]; then echo ':ssl_verify_mode: 0' >> ~/.gemrc && bundle config mirror.https://rubygems.org ${GEM_MIRROR}; fi \
    && bundle config set --local without 'development test' \
    && bundle install \
    && gem install passenger -v ${GEM_PASSENGER_VERSION} \
    && rvmsudo passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx \
    && if [ "$GEM_MIRROR" != "" ]; then bundle config unset mirror.https://rubygems.org/; fi

COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY start.sh /start.sh

EXPOSE 443 80

USER root
CMD ["/bin/bash", "-c", "/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf && chmod +x /start.sh && /start.sh && tail -f /opt/nginx/logs/*.log"]
