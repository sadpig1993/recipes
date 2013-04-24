-- ----------------------------
-- Table structure for tbl_role_inf
-- ----------------------------
drop table tbl_role_inf;

create table tbl_role_inf (
  role_id integer not null generated always as identity(start with 1,increment by 1,no cache),
  role_name varchar(100) not null,
  role_type varchar(100) default null,
  eff_date char(8) default null,
  exp_date char(8) default null,
  oper_staff integer not null,
  oper_date char(8) not null,
  status integer not null,
  remark varchar(200) default null
) in tbs_dat index in tbs_idx;

-- ----------------------------
-- Records of tbl_role_inf
-- ----------------------------
insert into tbl_role_inf(role_name, role_type, eff_date, exp_date, oper_staff, oper_date, status, remark) values ('超级管理员', '超级管理员角色', '20110311', '20610311', 1, '20121031', 0, '超级管理员');
