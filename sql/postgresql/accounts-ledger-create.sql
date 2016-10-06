-- accounts-ledger-create.sql

-- @author Benjamin Brink
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991

-- t/f values are converted to tcl 1/0 for api consistency

CREATE SEQUENCE qal_id start 10000;
SELECT nextval ('qal_id');


-- gets imported into qal_chart
-- Each account represents two traditional accounting columns:
-- debit column data is represented by positive values
-- credit column data is represented as negative values
CREATE TABLE qal_template_accounts (
    instance_id integer,
    chart_code  varchar(30),
    description text,
    charttype   varchar(5),
    gifi_accno  varchar(100),
    category    varchar(12),
    link        varchar(300),
    accno       varchar(100)
);

CREATE TABLE qal_chart_templates (
    instance_id integer,
    chart_code varchar(30),
    comments   text,
    title      varchar(200)
);

 -- gets imported to qal_defaults
CREATE TABLE qal_template_defaults (
    instance_id integer,
    chart_code  varchar(100),
    field_value text,
    field_name  varchar(200)
);

 -- gets imported to qal_tax
CREATE TABLE qal_template_taxes (
    instance_id integer,
    chart_code varchar(30),
    accno      varchar(100),
    taxnumber  text,
    rate       numeric
);


CREATE TABLE qal_gl (
  instance_id   integer,
  id            integer DEFAULT nextval ( 'qal_id' ),
  reference     text,
  description   text,
  transdate     date DEFAULT current_date,
  employee_id   integer,
  notes         text,
  department_id integer default 0
);

create index qal_gl_id_idx on qal_gl (id);
create index qal_gl_transdate_idx on qal_gl (transdate);
create index qal_gl_reference_idx on qal_gl (reference);
create index qal_gl_description_idx on qal_gl (lower(description));
create index qal_gl_employee_id_idx on qal_gl (employee_id);


CREATE TABLE qal_chart (
  instance_id integer,
  id          integer DEFAULT nextval ( 'qal_id' ),
  description text,
  charttype   char(1) DEFAULT 'A',
  gifi_accno  text,
  category    char(1),
  link        text,
  accno       text NOT NULL UNIQUE,
  contra      varchar(1) DEFAULT '0'
);

create index qal_chart_id_idx on qal_chart (id);
create index qal_chart_accno_idx on qal_chart (accno);
create index qal_chart_category_idx on qal_chart (category);
create index qal_chart_link_idx on qal_chart (link);
create index qal_chart_gifi_accno_idx on qal_chart (gifi_accno);


CREATE TABLE qal_defaults (
  instance_id        integer,
  inventory_accno_id integer,
  income_accno_id    integer,
  expense_accno_id   integer,
  fxgain_accno_id    integer,
  fxloss_accno_id    integer,
  sinumber           varchar(80),
  sonumber           varchar(80),
  yearend            varchar(5),
  closedto           date,
  revtrans           varchar(1) DEFAULT '0',
  ponumber           varchar(80),
  sqnumber           varchar(80),
  rfqnumber          varchar(80),
  vinumber           varchar(80),
  employeenumber     varchar(80),
  partnumber         varchar(80),
  customernumber     varchar(80),
  vendornumber       varchar(80),
  glnumber           varchar(80)
);


CREATE TABLE qal_acc_trans (
  instance_id     integer,
  trans_id        integer,
  chart_id        integer,
  amount          numeric,
  transdate       date DEFAULT current_date,
  source          varchar(300),
  cleared         varchar(1) DEFAULT '0',
  fx_transaction  varchar(1) DEFAULT '0',
  project_id      integer,
  memo            text
);

create index qal_acc_trans_trans_id_idx on qal_acc_trans (trans_id);
create index qal_acc_trans_chart_id_idx on qal_acc_trans (chart_id);
create index qal_acc_trans_transdate_idx on qal_acc_trans (transdate);
create index qal_acc_trans_source_idx on qal_acc_trans (lower(source));

 
CREATE TABLE qal_tax (
  instance_id integer,
  chart_id   integer,
  rate       numeric,
  tax_number text
);


CREATE TABLE qal_exchangerate (
  currency   varchar(3),
  trans_time timestamptz,
  buy        numeric,
  sell       numeric
);

create index qal_exchangerate_ct_idx on qal_exchangerate (currency);

CREATE TABLE qal_status (
  instance_id integer,
  trans_id  integer,
  formname  text,
  printed   varchar(1) default '0',
  emailed   varchar(1) default '0',
  spoolfile text,
  chart_id  integer
);

create index qal_status_trans_id_idx on qal_status (trans_id);


CREATE TABLE qal_department (
  instance_id integer,
  id          integer default nextval('qal_id'),
  description text,
  role        varchar(1) default 'P'
);

create index qal_department_id_idx on qal_department (id);

 -- department transaction table
CREATE TABLE qal_dept_trans_map (
  instance_id   integer,
  trans_id      integer,
  department_id integer
);

 -- business table ; really about discounts. renamed.
CREATE TABLE qal_discounts (
  instance_id integer,
  id          integer default nextval('qal_id'),
  description text,
  discount    numeric
);


CREATE TABLE qal_yearend (
  instance_id integer,
  trans_id integer,
  transdate date
);


-- language? currency? does this vary by instance_id?
CREATE TABLE qal_language (
  code        varchar(6) UNIQUE,
  description text
);

create index qal_language_code_idx on qal_language (code);


CREATE TABLE qal_translation (
  instance_id   integer,
  trans_id      integer,
  language_code varchar(6),
  description   text
);

create index qal_translation_trans_id_idx on qal_translation (trans_id);



