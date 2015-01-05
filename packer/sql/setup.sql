create database threedayrdbms character set utf8 collate utf8_unicode_ci;
create user 'dev'@'%' identified by 'dev';
grant all privileges on *.* to 'dev'@'%';
