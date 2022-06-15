-- create `prestashop` database

CREATE DATABASE IF NOT EXISTS `prestashop`;
GRANT ALL ON `prestashop`.* TO 'prestashop_admin'@'%';
