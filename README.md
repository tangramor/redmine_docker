# Redmine Docker image with Nginx + Passenger

This image is production ready.

Support MySQL for now.


## Versions/Tags

### Redmine 5.1.2 (tag [5.1.2](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.1.x), [latest](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.1.x) )

Based on **AlmaLinux 9** image. Ruby version **3.2.2**.

### Redmine 5.0.8 (tag [5.0.8](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.0.x) )

Based on **AlmaLinux 9** image. Ruby version **3.1.4**.

### Redmine 4.2.11 (tag [4.2.11](https://github.com/tangramor/redmine_docker/tree/master/redmine-4.2.11) )

Based on **CentOS 7** image. Ruby version **2.7.8**.

### Redmine 3.3.3 (tag [3.3.3](https://github.com/tangramor/redmine_docker/tree/master/redmine-3.3.3) )

This old version is using in our company, and the docker scripts were developped on it first.

Based on **CentOS 7** image. Ruby version **2.3.8**.

You need to notice the start options for MySQL 5.6 `--innodb-large-prefix=ON --innodb-file-format=Barracuda`. Without these opitons, the database migration will fail.


## Usage

For each version/tag, there are related `docker-compose.yml` file and `config` folder. You can find them by click the tag's link to Github repository.

Please edit database **user/password** in `docker-compose.yml`, `config/database.yml` and `initial.sql`:

- MySQL `root` user: default password `Password1`
- MySQL `redmine` user: default password `Password2`

For version **3.3.3** or **4.2.11**, please edit the **LOCALE** environment variable in `docker-compose.yml` to support different languages, such as `LOCALE=zh_CN.UTF-8`.

Please edit the volumes mapping in `docker-compose.yml`.

- Redmine data: `/home/redmine`
- MySQL data: `/home/mysql<version>_data`

### Launch containers

Then you can use `docker compose up -d` to launch the containers. The scripts will automatically create `redmine` databases and execute `rake db:migrate`, `rake generate_secret_token` commands.

***Note***: If you don't want to run `rake db:migrage` but import database by yourself, create an empty file `config/init_db.lock`.

Once the setup process is done, you can use `docker ps` or `docker compose ps` command to check the `healthy` status of the containers. It costs about 2 minutes.


### Load database default dataset

You may want load default dataset according to https://www.redmine.org/projects/redmine/wiki/RedmineInstall#Step-7-Database-default-data-set . Following are the steps:

```bash
# enter container
docker exec -it -u service -w /var/www/html/redmine redmine bash

# load .bash_profile
$ source ~/.bash_profile

# load default dataset
$ RAILS_ENV=production REDMINE_LANG=zh bundle exec rake redmine:load_default_data
```


### Logging into the application

Use default administrator account to log in http://127.0.0.1 :

- login: `admin`
- password: `admin`


### Secret

The docker scripts generated `SECRET_KEY_BASE` environment variable. If you want to regenerate it, you may execute following commands:

```bash
docker exec -i redmine sed -i '/SECRET_KEY_BASE/d' /home/service/.bash_profile
docker exec -i redmine rm -f /var/www/html/redmine/config/init_secret.lock
docker exec -i redmine bash -c /start.sh
```

### Add Plugins

For example, install [redmine_agile](https://www.redmineup.com/pages/plugins/agile). You registered an email to get the download link for the free edition and downloaded **redmine_agile-x_x_x-light.zip**. Copy this file to `/home/redmine/plugins` (in my case), and execute following commands:

```bash
# enter container
docker exec -it -u service -w /var/www/html/redmine redmine bash

# load .bash_profile
$ source ~/.bash_profile

# unzip plugin archive
$ cd plugins
$ unzip -a redmine_agile-x_x_x-light.zip

# Install required gems
$ cd ..
$ bundle install --without development test --no-deployment

# Migrate plugin's tables
$ bundle exec rake redmine:plugins NAME=redmine_agile RAILS_ENV=production

# Restart Redmine app
$ touch tmp/restart.txt
```
