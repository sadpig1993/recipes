#!/bin/bash

db2 connect to $DB_NAME user ypinst using ypinst;
db2 set current schema $DB_SCHEMA;

# db2 -tvf tbl_holi_inf.sql;

for file in `ls *.sql`; do
  echo $file;
  db2 -tvf $file;
done

