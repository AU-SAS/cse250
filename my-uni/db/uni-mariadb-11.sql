create table student
(
    id   int auto_increment
        primary key,
    name varchar(50) not null comment 'full name'
);

create table teacher
(
    id   smallint unsigned auto_increment
        primary key,
    name varchar(100) not null comment 'full name'
);

