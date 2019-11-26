create user 'pma'@'localhost' identified by 'pmapass';
grant all on *.* to 'pma'@'localhost' with grant option;
create database wordpress;
flush privileges;
