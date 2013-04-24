-- ----------------------------
-- Table structure for tbl_route_inf
-- ----------------------------
drop table tbl_route_inf;

create table tbl_route_inf (
  route_id integer not null generated always as identity(start with 1,increment by 1,no cache),
  parent_id integer default null,
  route_name varchar(100) not null,
  route_value varchar(500) default null,
  route_regex varchar(500) default null,
  view_order integer default null,
  oper_staff integer not null,
  oper_date char(8) not null,
  status integer not null,
  remark varchar(255) default null
) in tbs_dat index in tbs_idx;

-- ----------------------------
-- Records of tbl_route_inf
-- ----------------------------
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, '系统' , '', '',  1, 0, '20121101', 1, '系统菜单');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(1, '重新登录' , 'javascript:window.open(''/'',''_parent'')', '', 1, 0, '20121101', 1, '重新登录菜单项');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(1, '密码设置' ,'/login/reset_password' ,'^/login/reset_password$' , 2, 0, '20121101', 1, '密码设置菜单项');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, 'role' , '', '', 2, 0, '20121101', 1, 'role');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(4, 'user' , '/user/index', '^/user/.*$', 1, 0, '20121101', 1, '用户管理菜单项');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(4, 'role' , '/role/index', '^/role/.*$', 2, 0, '20121101', 1, '角色管理菜单项');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, 'ypos' , '', '', 2, 0, '20121101', 1, 'ypos管理菜单');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(7, 'ypos签到' , '/ypos/list', '^/ypos/(list|si)$', 1, 0, '20121101', 1, 'ypos签到菜单');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(7, '交易监控' , '/ypos/monitoring', '^/ypos/monitoring$', 2, 0, '20121101', 1, '交易监控菜单');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(7, '交易查询' , '/ypos/index', '^/ypos/index$', 3, 0, '20121101', 1, '交易监控菜单');


insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, 'bank' , '', '', 2, 0, '20121101', 1, 'role');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(11, 'bank1' , '/bank/index', '^/bank/.*$', 1, 0, '20121101', 1, '用户管理菜单项');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(11, 'bank2' , '/role/index', '^/role/.*$', 2, 0, '20121101', 1, '角色管理菜单项');
