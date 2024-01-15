CREATE DATABASE redmine CHARACTER SET utf8mb4;
CREATE USER 'redmine'@'%' IDENTIFIED BY 'Password2';
GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'%';
