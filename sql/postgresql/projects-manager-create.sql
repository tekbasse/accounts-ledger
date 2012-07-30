-- accounts-ledger-create.sql
--
-- @porting by Dekka Corp.
-- @copyright Copyright (c) 1999 - 2005, DWS Systems Inc.
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id

--  This table will eventually be *somehow* integrated with project-manager package

CREATE TABLE qal_project (
  id integer default nextval('qal_id'),
  projectnumber varchar(200),
  description text,
  startdate date,
  enddate date,
  parts_id integer,
  production numeric default 0,
  completed numeric default 0,
  customer_id integer
);


create index qal_project_id_key on qal_project (id);
create unique index projectnumber_key on qal_project (projectnumber);
