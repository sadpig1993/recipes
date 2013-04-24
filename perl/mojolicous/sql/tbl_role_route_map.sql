-- ----------------------------
-- Table structure for tbl_role_route_map
-- ----------------------------
drop table tbl_role_route_map;

create table tbl_role_route_map (
  role_id integer not null,
  route_id integer not null
) in tbs_dat index in tbs_idx;

-- ----------------------------
-- Records of tbl_role_route_map
-- ----------------------------
insert into tbl_role_route_map(role_id, route_id) values (1, 1);
insert into tbl_role_route_map(role_id, route_id) values (1, 2);
insert into tbl_role_route_map(role_id, route_id) values (1, 3);
insert into tbl_role_route_map(role_id, route_id) values (1, 4);
insert into tbl_role_route_map(role_id, route_id) values (1, 5);
insert into tbl_role_route_map(role_id, route_id) values (1, 6);
insert into tbl_role_route_map(role_id, route_id) values (1, 7);
insert into tbl_role_route_map(role_id, route_id) values (1, 8);
insert into tbl_role_route_map(role_id, route_id) values (1, 9);
insert into tbl_role_route_map(role_id, route_id) values (1, 10);
