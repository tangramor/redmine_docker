# Redmine Docker image with Nginx + Passenger

This image is production ready.

Support MySQL for now.

Please edit database user/password in `config/database.yml` and `initial.sql`.

## version 3.3.3

This old version is using in our company, and the docker scripts were developped on it first.

You need to notice the start options for MySQL 5.6 `--innodb-large-prefix=ON --innodb-file-format=Barracuda`. Without these opitons, the database migration will fail.