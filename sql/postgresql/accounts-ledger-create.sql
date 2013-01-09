-- accounts-ledger-create.sql

-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991


CREATE SEQUENCE qal_id start 10000;
SELECT nextval ('qal_id');


-- gets imported into qal_chart
-- Each account represents two traditional accounting columns:
-- debit column data is represented by positive values
-- credit column data is represented as negative values
CREATE TABLE qal_template_accounts (
    chart_code  varchar(30),
    description text,
    charttype   varchar(5),
    gifi_accno  varchar(100),
    category    varchar(12),
    link        varchar(300),
    accno       varchar(100)
);

CREATE TABLE qal_chart_templates (
    chart_code varchar(30),
    comments   text,
    title      varchar(200)
);

 -- gets imported to qal_defaults
CREATE TABLE qal_template_defaults (
    chart_code  varchar(100),
    field_value text,
    field_name  varchar(200)
);

 -- gets imported to qal_tax
CREATE TABLE qal_template_taxes (
    chart_code varchar(30),
    accno      varchar(100),
    taxnumber  text,
    rate       numeric
);


CREATE TABLE qal_gl (
  id            integer DEFAULT nextval ( 'qal_id' ),
  reference     text,
  description   text,
  transdate     date DEFAULT current_date,
  employee_id   integer,
  notes         text,
  department_id integer default 0
);


CREATE TABLE qal_chart (
  id          integer DEFAULT nextval ( 'qal_id' ),
  description text,
  charttype   char(1) DEFAULT 'A',
  gifi_accno  text,
  category    char(1),
  link        text,
  accno       text NOT NULL,
  contra      varchar(1) DEFAULT 'f'
);

CREATE TABLE qal_defaults (
  inventory_accno_id integer,
  income_accno_id    integer,
  expense_accno_id   integer,
  fxgain_accno_id    integer,
  fxloss_accno_id    integer,
  sinumber           varchar(80),
  sonumber           varchar(80),
  yearend            varchar(5),
  closedto           date,
  revtrans           varchar(1) DEFAULT 'f',
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
  trans_id        integer,
  chart_id        integer,
  amount          numeric,
  transdate       date DEFAULT current_date,
  source          text,
  cleared         varchar(1) DEFAULT 'f',
  fx_transaction  varchar(1) DEFAULT 'f',
  project_id      integer,
  memo            text
);

 
CREATE TABLE qal_tax (
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



CREATE TABLE qal_status (
  trans_id  integer,
  formname  text,
  printed   varchar(1) default 'f',
  emailed   varchar(1) default 'f',
  spoolfile text,
  chart_id  integer
);

CREATE TABLE qal_department (
  id          integer default nextval('qal_id'),
  description text,
  role        varchar(1) default 'P'
);

 -- department transaction table
CREATE TABLE qal_dept_trans_map (
  trans_id      integer,
  department_id integer
);

 -- business table
CREATE TABLE qal_business (
  id          integer default nextval('qal_id'),
  description text,
  discount    numeric
);


CREATE TABLE qal_yearend (
  trans_id integer,
  transdate date
);


CREATE TABLE qal_language (
  code        varchar(6),
  description text
);

CREATE TABLE qal_translation (
  trans_id      integer,
  language_code varchar(6),
  description   text
);


create index qal_acc_trans_trans_id_key on qal_acc_trans (trans_id);
create index qal_acc_trans_chart_id_key on qal_acc_trans (chart_id);
create index qal_acc_trans_transdate_key on qal_acc_trans (transdate);
create index qal_acc_trans_source_key on qal_acc_trans (lower(source));


create index qal_chart_id_key on qal_chart (id);
create unique index qal_chart_accno_key on qal_chart (accno);
create index qal_chart_category_key on qal_chart (category);
create index qal_chart_link_key on qal_chart (link);
create index qal_chart_gifi_accno_key on qal_chart (gifi_accno);

create index qal_exchangerate_ct_key on qal_exchangerate (curr, transdate);

create index qal_gl_id_key on qal_gl (id);
create index qal_gl_transdate_key on qal_gl (transdate);
create index qal_gl_reference_key on qal_gl (reference);
create index qal_gl_description_key on qal_gl (lower(description));
create index qal_gl_employee_id_key on qal_gl (employee_id);


create index qal_status_trans_id_key on qal_status (trans_id);

create index qal_department_id_key on qal_department (id);



create index qal_translation_trans_id_key on qal_translation (trans_id);

create unique index qal_language_code_key on qal_language (code);


