-- create `test_prestashop` database

CREATE DATABASE IF NOT EXISTS `test_prestashop`;
GRANT ALL ON `test_prestashop`.* TO 'prestashop_admin'@'%';
