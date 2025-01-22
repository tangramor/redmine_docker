# Redmine Docker image with Nginx + Passenger

This image is production ready.

Support MySQL for now.


## Versions/Tags

### Redmine 6.0.2 (tag [6.0.2](https://github.com/tangramor/redmine_docker/tree/master/redmine-6.x.x), [latest](https://github.com/tangramor/redmine_docker/tree/master/redmine-6.x.x) )

Based on **AlmaLinux 9** image. Ruby version **3.3.7**.

```
Environment:
  Redmine version                6.0.2.stable
  Ruby version                   3.3.7-p123 (2025-01-15) [x86_64-linux]
  Rails version                  7.2.2
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
Redmine settings:
  Redmine theme                  Default
SCM:
  Subversion                     1.14.1
  Git                            2.43.5
  Filesystem                     
Redmine plugins:
  no plugin installed
```

### Redmine 5.1.5 (tag [5.1.5](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.1.x) )

Based on **AlmaLinux 9** image. Ruby version **3.2.6**.

```
Environment:
  Redmine version                5.1.5.stable
  Ruby version                   3.2.6-p234 (2024-10-30) [x86_64-linux]
  Rails version                  6.1.7.10
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
Redmine settings:
  Redmine theme                  Default
SCM:
  Subversion                     1.14.1
  Git                            2.43.5
  Filesystem                     
Redmine plugins:
  no plugin installed
```

### Redmine 5.0.10 (tag [5.0.10](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.0.x) )

Based on **AlmaLinux 9** image. Ruby version **3.1.6**.

```
Environment:
  Redmine version                5.0.10.stable
  Ruby version                   3.1.6-p260 (2024-05-29) [x86_64-linux]
  Rails version                  6.1.7.10
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
Redmine settings:
  Redmine theme                  Default
SCM:
  Subversion                     1.14.1
  Git                            2.43.5
  Filesystem                     
Redmine plugins:
  no plugin installed
```

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


# 中文说明

这个镜像已可用于生产环境。

目前仅支持 MySQL。

## 版本/标签

### Redmine 6.0.2 (标签 [6.0.2](https://github.com/tangramor/redmine_docker/tree/master/redmine-6.x.x), [latest](https://github.com/tangramor/redmine_docker/tree/master/redmine-6.x.x) )

基于 **AlmaLinux 9** 镜像。Ruby 版本 **3.3.7** 。

```
Environment:
  Redmine version                6.0.2.stable
  Ruby version                   3.3.7-p123 (2025-01-15) [x86_64-linux]
  Rails version                  7.2.2
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
Redmine settings:
  Redmine theme                  Default
SCM:
  Subversion                     1.14.1
  Git                            2.43.5
  Filesystem                     
Redmine plugins:
  no plugin installed
```

### Redmine 5.1.5 (标签 [5.1.5](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.1.x) )

基于 **AlmaLinux 9** 镜像。Ruby 版本 **3.2.6** 。

```
Environment:
  Redmine version                5.1.5.stable
  Ruby version                   3.2.6-p234 (2024-10-30) [x86_64-linux]
  Rails version                  6.1.7.10
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
Redmine settings:
  Redmine theme                  Default
SCM:
  Subversion                     1.14.1
  Git                            2.43.5
  Filesystem                     
Redmine plugins:
  no plugin installed
```

### Redmine 5.0.10 (标签 [5.0.10](https://github.com/tangramor/redmine_docker/tree/master/redmine-5.0.x) )

基于 **AlmaLinux 9** 镜像。Ruby 版本 **3.1.6** 。

```
Environment:
  Redmine version                5.0.10.stable
  Ruby version                   3.1.6-p260 (2024-05-29) [x86_64-linux]
  Rails version                  6.1.7.10
  Environment                    production
  Database adapter               Mysql2
  Mailer queue                   ActiveJob::QueueAdapters::AsyncAdapter
  Mailer delivery                smtp
Redmine settings:
  Redmine theme                  Default
SCM:
  Subversion                     1.14.1
  Git                            2.43.5
  Filesystem                     
Redmine plugins:
  no plugin installed
```

### Redmine 4.2.11 (标签 [4.2.11](https://github.com/tangramor/redmine_docker/tree/master/redmine-4.2.11) )

基于 **CentOS 7** 镜像。Ruby 版本 **2.7.8** 。

### Redmine 3.3.3 (标签 [3.3.3](https://github.com/tangramor/redmine_docker/tree/master/redmine-3.3.3) )

这个旧版本在我们公司中使用，docker脚本最初是针对它开发的。

基于 **CentOS 7** 镜像。Ruby 版本 **2.3.8** 。

您需要注意对于 MySQL 5.6 的启动选项 `--innodb-large-prefix=ON --innodb-file-format=Barracuda`。如果没有这些选项，数据库迁移将失败。


## 使用方法

对于每个版本/标签，都有相关的 `docker-compose.yml` 文件和 `config` 文件夹。您可以通过单击标签的链接到Github存储库中查找它们。

请编辑 `docker-compose.yml`、`config/database.yml` 和 `initial.sql` 中的数据库 **用户名/密码**：

- MySQL `root` 用户：默认密码 `Password1`
- MySQL `redmine` 用户：默认密码 `Password2`

对于版本 **3.3.3** 或 **4.2.11**，请编辑 `docker-compose.yml` 中的 **LOCALE** 环境变量以支持不同的语言，例如 `LOCALE=zh_CN.UTF-8`。

请编辑 `docker-compose.yml` 中的卷映射。

- Redmine 数据：`/home/redmine`
- MySQL 数据：`/home/mysql<version>_data`

### 启动容器

然后可以使用 `docker compose up -d` 命令启动容器。脚本将自动创建 `redmine` 数据库并执行 `rake db:migrate`、`rake generate_secret_token` 命令。

***注意***：如果您不想运行 `rake db:migrage` 而是自行导入数据库，请创建一个空文件 `config/init_db.lock`。

完成设置后，您可以使用 `docker ps` 或 `docker compose ps` 命令检查容器的 `healthy` 状态，大约需要 2 分钟。

### 加载数据库默认数据集

您可能想要根据 https://www.redmine.org/projects/redmine/wiki/RedmineInstall#Step-7-Database-default-data-set 加载默认数据集。以下是步骤：

```bash
# 进入容器
docker exec -it -u service -w /var/www/html/redmine redmine bash

# 加载 .bash_profile
$ source ~/.bash_profile

# 加载默认数据集
$ RAILS_ENV=production REDMINE_LANG=zh bundle exec rake redmine:load_default_data
```


### 登录应用程序

使用默认管理员账户登录 http://127.0.0.1 ：

- 登录名: `admin`
- 密码: `admin`


### 密钥

Docker 脚本生成了 `SECRET_KEY_BASE` 环境变量。如果您想重新生成它，可以执行以下命令：

```bash
docker exec -i redmine sed -i '/SECRET_KEY_BASE/d' /home/service/.bash_profile
docker exec -i redmine rm -f /var/www/html/redmine/config/init_secret.lock
docker exec -i redmine bash -c /start.sh
```


### 添加插件

例如，安装 [redmine_agile](https://www.redmineup.com/pages/plugins/agile)。您注册了一个邮箱以获取免费版本的下载链接，并下载了 **redmine_agile-x_x_x-light.zip**。将此文件复制到 `/home/redmine/plugins`（以我的情况为例），并执行以下命令：

```bash
# 进入容器
docker exec -it -u service -w /var/www/html/redmine redmine bash

# 加载 .bash_profile
$ source ~/.bash_profile

# 解压插件归档文件
$ cd plugins
$ unzip -a redmine_agile-x_x_x-light.zip

# 安装所需的 gem 包
$ cd ..
$ bundle install --without development test --no-deployment

# 迁移插件的数据表
$ bundle exec rake redmine:plugins NAME=redmine_agile RAILS_ENV=production

# 重启 Redmine 应用程序
$ touch tmp/restart.txt
```


