use threedayrdbms;

create table dog_breeds (
       breed_name	varchar(50),
       characteristics	varchar(100)
);

insert into dog_breeds (breed_name, characteristics)
values ('border collie', 'ankle-biter'),
       ('golden retriever', 'vicious killer');
       
