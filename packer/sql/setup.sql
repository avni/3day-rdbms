create database threedayrdbms character set utf8 collate utf8_unicode_ci;
create user 'vagrant'@'%';
grant all privileges on *.* to 'vagrant'@'%';
