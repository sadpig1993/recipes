/*
drop table yspz_test;
drop table book_test;
drop table jzpz_test;
*/

-- 创建table yspz_test 主键自赠
create table yspz_test ( 
  id integer not null generated always as identity,
  name char(32) not null unique,
  primary key(id)
);

-- 创建table book_test主键自赠
create table book_test ( 
  id integer not null generated always as identity,
  yspz_id integer not null ,
  name char(32) not null unique,
  primary key(id)
);

-- 创建table jzpz_test主键自赠
create table jzpz_test ( 
  id integer not null generated always as identity,
  yspz_id integer not null ,
  book_id integer not null ,
  name char(32),
  primary key(id)
);

/*
    此种情况下调用存储过程 call TESTMY('yspz', 'book')
*/


-- select * from syscat.tables where tbspaceid=2 and tableid=18

values nextval for seq_yspz1;
select seq_yspz1.nextval from system.dual
-- 创建table yspz1_test sequence
create table yspz1_test ( 
  id bigint primary key not null,
  name char(32)
);
create sequence seq_yspz1 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- 创建table book1_test
create table book1_test ( 
  id bigint primary key not null,
  yspz_id bigint not null,
  name char(32)
);
create sequence seq_book1 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- 创建table jzpz
create table jzpz1_test ( 
  id bigint primary key not null,
  yspz_id bigint not null,
  book_id bigint not null,
  name char(32)
);
create sequence seq_jzpz1 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

/*
    此种情况下调用存储过程 call TESTMY('yspz1', 'book1')
*/
