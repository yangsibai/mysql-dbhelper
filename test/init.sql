create database test;

create table test(
	id integer primary key auto_increment,
	name varchar(10)
)

insert into test(name) values("name1");
insert into test(name) values("name2");
insert into test(name) values("name3");
insert into test(name) values("name4");
insert into test(name) values("name5");
insert into test(name) values("name6");
insert into test(name) values("name7");
insert into test(name) values("name8");

--execute this line after test
--drop database test;