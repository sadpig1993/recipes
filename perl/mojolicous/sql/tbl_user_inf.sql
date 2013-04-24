-- ----------------------------
-- Table structure for tbl_user_inf
-- ----------------------------
drop table tbl_user_inf;

create table tbl_user_inf (
  user_id integer not null generated always as identity(start with 1,increment by 1,no cache),
  username varchar(100) default null,
  user_pwd varchar(255) not null,
  pwd_chg_date char(8) default null,
  eff_date char(8) default null,
  exp_date char(8) default null,
  oper_staff integer default null,
  oper_date char(8) default null,
  status integer not null
) in tbs_dat index in tbs_idx;

-- ----------------------------
-- Records of tbl_user_inf
-- ----------------------------
insert into tbl_user_inf(username, user_pwd, pwd_chg_date, eff_date, exp_date, oper_staff, oper_date, status) 
values('admin', '0192023a7bbd73250516f069df18b500', '20121101', '20121101', '20500101',0 , '20121101', 1 );
