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
values(0, 'ϵͳ' , '', '',  1, 0, '20121101', 1, 'ϵͳ�˵�');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(1, '���µ�¼' , 'javascript:window.open(''/'',''_parent'')', '', 1, 0, '20121101', 1, '���µ�¼�˵���');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(1, '��������' ,'/login/reset_password' ,'^/login/reset_password$' , 2, 0, '20121101', 1, '�������ò˵���');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, 'role' , '', '', 2, 0, '20121101', 1, 'role');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(4, 'user' , '/user/index', '^/user/.*$', 1, 0, '20121101', 1, '�û�����˵���');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(4, 'role' , '/role/index', '^/role/.*$', 2, 0, '20121101', 1, '��ɫ����˵���');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, 'ypos' , '', '', 2, 0, '20121101', 1, 'ypos����˵�');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(7, 'yposǩ��' , '/ypos/list', '^/ypos/(list|si)$', 1, 0, '20121101', 1, 'yposǩ���˵�');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(7, '���׼��' , '/ypos/monitoring', '^/ypos/monitoring$', 2, 0, '20121101', 1, '���׼�ز˵�');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(7, '���ײ�ѯ' , '/ypos/index', '^/ypos/index$', 3, 0, '20121101', 1, '���׼�ز˵�');


insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(0, 'bank' , '', '', 2, 0, '20121101', 1, 'role');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(11, 'bank1' , '/bank/index', '^/bank/.*$', 1, 0, '20121101', 1, '�û�����˵���');
insert into tbl_route_inf(parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, remark) 
values(11, 'bank2' , '/role/index', '^/role/.*$', 2, 0, '20121101', 1, '��ɫ����˵���');
