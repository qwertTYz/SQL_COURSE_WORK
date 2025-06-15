-- for OLAP
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS oltp_fdw CASCADE;

CREATE SERVER oltp_fdw
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (
    host 'localhost',
    port '5432',
    dbname 'COURSE_WORK_OLTP'
);

DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER oltp_fdw;

CREATE USER MAPPING FOR CURRENT_USER
  SERVER oltp_fdw
  OPTIONS (
    user     'postgres',
    password 'password'
);

DROP SCHEMA IF EXISTS staging CASCADE;
CREATE SCHEMA staging;

IMPORT FOREIGN SCHEMA public
  FROM SERVER oltp_fdw
  INTO staging;
  
  