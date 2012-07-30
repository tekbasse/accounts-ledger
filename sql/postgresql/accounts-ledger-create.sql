-- accounts-ledger-create.sql
--
-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id
--

CREATE SEQUENCE qal_id start 10000;
SELECT nextval ('qal_id');


-- gets imported into qal_chart
-- Each account represents two traditional accounting columns:
-- debit column data is represented by positive values
-- credit column data is represented as negative values
CREATE TABLE qal_template_accounts (
    chart_code varchar(30),
    description text,
    charttype varchar(5),
    gifi_accno varchar(100),
    category varchar(3),
    link varchar(300),
    accno varchar(100)
);

CREATE TABLE qal_chart_templates (
    chart_code varchar(30),
    comments text,
    title varchar(200)
);

-- gets imported to qal_defaults
CREATE TABLE qal_template_defaults (
    chart_code varchar(100),
    field_value text,
    field_name varchar(200)
);

--gets imported to qal_tax
CREATE TABLE qal_template_taxes (
    chart_code varchar(30),
    accno varchar(100),
    taxnumber text,
    rate numeric
);

--
CREATE TABLE qal_gl (
  id int DEFAULT nextval ( 'qal_id' ),
  reference text,
  description text,
  transdate date DEFAULT current_date,
  employee_id integer,
  notes text,
  department_id integer default 0
);

--
CREATE TABLE qal_chart (
  id int DEFAULT nextval ( 'qal_id' ),
  description text,
  charttype char(1) DEFAULT 'A',
  gifi_accno text,
  category char(1),
  link text,
  accno text NOT NULL,
  contra bool DEFAULT 'f'
);

--
-- the package related defaults should be moved from this table into package parameters
-- some are related to user and so should stay in a user_preferences table
-- 
CREATE TABLE qal_defaults (
  inventory_accno_id integer,
  income_accno_id integer,
  expense_accno_id integer,
  fxgain_accno_id integer,
  fxloss_accno_id integer,
  sinumber text,
  sonumber text,
  yearend varchar(5),
  weightunit varchar(5),
  businessnumber text,
  version varchar(8),
  curr text,
  closedto date,
  revtrans bool DEFAULT 'f',
  ponumber text,
  sqnumber text,
  rfqnumber text,
  audittrail bool default 'f',
  vinumber text,
  employeenumber text,
  partnumber text,
  customernumber text,
  vendornumber text,
  glnumber text
);

INSERT INTO qal_defaults (version) VALUES ('2.6.2');

--
CREATE TABLE qal_acc_trans (
  trans_id integer,
  chart_id integer,
  amount numeric,
  transdate date DEFAULT current_date,
  source text,
  cleared bool DEFAULT 'f',
  fx_transaction bool DEFAULT 'f',
  project_id integer,
  memo text
);

-- 
CREATE TABLE qal_tax (
  chart_id integer,
  rate numeric,
  taxnumber text
);
--

--  no customer table here, but maybe there should be a customer account to handle
--  the GL related attributes such as credit limit.

CREATE TABLE qal_exchangerate (
  curr char(3),
  transdate date,
  buy numeric,
  sell numeric
);

--
--
CREATE TABLE qal_status (
  trans_id integer,
  formname text,
  printed bool default 'f',
  emailed bool default 'f',
  spoolfile text,
  chart_id integer
);
--
CREATE TABLE qal_department (
  id int default nextval('qal_id'),
  description text,
  role char(1) default 'P'
);
--
-- department transaction table
CREATE TABLE qal_dpt_trans (
  trans_id integer,
  department_id integer
);
--
-- business table
CREATE TABLE qal_business (
  id integer default nextval('qal_id'),
  description text,
  discount numeric
);
--
--
CREATE TABLE qal_yearend (
  trans_id integer,
  transdate date
);

--
CREATE TABLE qal_language (
  code varchar(6),
  description text
);
--
CREATE TABLE qal_audittrail (
  trans_id integer,
  tablename text,
  reference text,
  formname text,
  action text,
  transdate timestamp default current_timestamp,
  employee_id int
);
--
CREATE TABLE qal_translation (
  trans_id integer,
  language_code varchar(6),
  description text
);


create index qal_acc_trans_trans_id_key on qal_acc_trans (trans_id);
create index qal_acc_trans_chart_id_key on qal_acc_trans (chart_id);
create index qal_acc_trans_transdate_key on qal_acc_trans (transdate);
create index qal_acc_trans_source_key on qal_acc_trans (lower(source));

--
create index qal_chart_id_key on qal_chart (id);
create unique index qal_chart_accno_key on qal_chart (accno);
create index qal_chart_category_key on qal_chart (category);
create index qal_chart_link_key on qal_chart (link);
create index qal_chart_gifi_accno_key on qal_chart (gifi_accno);
--
create index qal_exchangerate_ct_key on qal_exchangerate (curr, transdate);
--
create index qal_gl_id_key on qal_gl (id);
create index qal_gl_transdate_key on qal_gl (transdate);
create index qal_gl_reference_key on qal_gl (reference);
create index qal_gl_description_key on qal_gl (lower(description));
create index qal_gl_employee_id_key on qal_gl (employee_id);

--
create index qal_status_trans_id_key on qal_status (trans_id);
--
create index qal_department_id_key on qal_department (id);

--
create index qal_audittrail_trans_id_key on qal_audittrail (trans_id);
--
create index qal_translation_trans_id_key on qal_translation (trans_id);
--
create unique index qal_language_code_key on qal_language (code);
--


--
CREATE FUNCTION qal_del_yearend() RETURNS OPAQUE AS '
begin
  delete from qal_yearend where trans_id = old.id;
  return NULL;
end;
' language 'plpgsql';
-- end function
--
CREATE TRIGGER qal_del_yearend AFTER DELETE ON qal_gl FOR EACH ROW EXECUTE PROCEDURE qal_del_yearend();
-- end trigger
--
CREATE FUNCTION qal_del_department() RETURNS OPAQUE AS '
begin
  delete from qal_dpt_trans where trans_id = old.id;
  return NULL;
end;
' language 'plpgsql';
-- end function
--
CREATE TRIGGER qal_del_department AFTER DELETE ON qal_gl FOR EACH ROW EXECUTE PROCEDURE qal_del_department();
-- end trigger

--

--
CREATE FUNCTION qal_check_department() RETURNS OPAQUE AS '

declare
  dpt_id int;

begin
 
  if new.department_id = 0 then
    delete from qal_dpt_trans where trans_id = new.id;
    return NULL;
  end if;

  select into dpt_id trans_id from qal_dpt_trans where trans_id = new.id;
  
  if dpt_id > 0 then
    update qal_dpt_trans set department_id = new.department_id where trans_id = dpt_id;
  else
    insert into qal_dpt_trans (trans_id, department_id) values (new.id, new.department_id);
  end if;
return NULL;

end qal_check_department;
' language 'plpgsql';
-- end function
--
CREATE TRIGGER qal_check_department AFTER INSERT OR UPDATE ON qal_gl FOR EACH ROW EXECUTE PROCEDURE qal_check_department();
-- end trigger
--
--


-- qal_del_exchangerate has dependencies on AR and AP, 
-- but AR and AP have triggers that depend on it, so hopefully
-- it works from here, otherwise we might need to split this up
CREATE FUNCTION qal_del_exchangerate() RETURNS OPAQUE AS '

declare
  t_transdate date;
  t_curr char(3);
  t_id int;
  d_curr text;

begin

  select into d_curr substr(curr,1,3) from qal_defaults;
  
  if TG_RELNAME = ''ar'' then
    select into t_curr, t_transdate curr, transdate from qar_ar where id = old.id;
  end if;
  if TG_RELNAME = ''ap'' then
    select into t_curr, t_transdate curr, transdate from qap_ap where id = old.id;
  end if;
  if TG_RELNAME = ''oe'' then
    select into t_curr, t_transdate curr, transdate from qar_oe where id = old.id;
  end if;

  if d_curr != t_curr then

    select into t_id a.id from qal_acc_trans ac
    join qar_ar a on (a.id = ac.trans_id)
    where a.curr = t_curr
    and ac.transdate = t_transdate

    except select a.id from qar_ar a where a.id = old.id
    
    union
    
    select a.id from qal_acc_trans ac
    join qap_ap a on (a.id = ac.trans_id)
    where a.curr = t_curr
    and ac.transdate = t_transdate
    
    except select a.id from qap_ap a where a.id = old.id
    
    union
    
    select o.id from qar_oe o
    where o.curr = t_curr
    and o.transdate = t_transdate
    
    except select o.id from qar_oe o where o.id = old.id;

    if not found then
      delete from qal_exchangerate where curr = t_curr and transdate = t_transdate;
    end if;
  end if;
return old;

end;
' language 'plpgsql';
-- end function
--


   create sequence qal_ec_user_session_seq;
   create view qal_ec_user_session_sequence as select nextval('qal_ec_user_session_seq') as nextval;
   
   create table qal_ec_user_sessions (
           user_session_id         integer not null constraint qal_ec_session_id_pk primary key,
           -- often will not be known
           user_id                 integer references users,
           ip_address              varchar(20) not null,
           start_time              timestamptz,
           http_user_agent         varchar(4000)
   );
   
   create index qal_ec_user_sessions_idx on qal_ec_user_sessions(user_id);
   
   create table qal_ec_user_session_info (
           user_session_id         integer not null references qal_ec_user_sessions,
           product_id              integer references qci_ec_products,
--     used to reference ec_categories, now needs to reference categories package..
--           category_id             integer references qci_ec_categories,
           category_id             integer,
           search_text             varchar(200)
   );
   
   create index qal_ec_user_session_info_idx  on qal_ec_user_session_info (user_session_id);
   create index qal_ec_user_session_info_idx2 on qal_ec_user_session_info (product_id);
   create index qal_ec_user_session_info_idx3 on qal_ec_user_session_info (category_id);
   
