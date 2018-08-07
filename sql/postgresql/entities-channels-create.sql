-- accounts-contacts-create.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package

-- Every vendor requires a contact record
-- Every customer requires a contact record


CREATE TABLE qal_customer_object_id_map (
       object_id integer unique not null,
       instance_id integer,
       -- For now, customer_id is the same as object_id. See qal_customer table.
       -- acs_object_type__create_type needs an external table.
       customer_id integer
);       

create index qal_customer_object_id_map_customer_id_idx on qal_customer_object_id_map(customer_id);
create index qal_customer_object_id_map_instance_id_idx on qal_customer_object_id_map(instance_id);

select acs_object_type__create_type(
   'qal_grps_customer',          -- content_type
   'qal Customer Group',         -- pretty_name 
   'qal Customer Groups',        -- pretty_plural
   'acs_object',                 -- supertype
   'qal_customer_object_id_map', -- table_name
   'object_id',                  -- id_column
   'qal_groups_customer',        -- package_name
   'f',                          -- abstract_p
   NULL,                         -- type_extension_table
   NULL                          -- name_method
);


CREATE TABLE qal_vendor_object_id_map (
       object_id integer unique not null,
       instance_id integer,
       -- For now, vendor_id is the same as object_id. See qal_vendor table.
       -- acs_object_type__create_type needs an external table.
       vendor_id integer
);       

create index qal_vendor_object_id_map_vendor_id_idx on qal_vendor_object_id_map(vendor_id);
create index qal_vendor_object_id_map_instance_id_idx on qal_vendor_object_id_map(instance_id);

select acs_object_type__create_type(
   'qal_grps_vendor',           -- content_type
   'qal Vendor Group',          -- pretty_name 
   'qal Vendor Groups',         -- pretty_plural
   'acs_object',                -- supertype
   'qal_vendor_object_id_map',  -- table_name 
   'object_id',                 -- id_column
   'qal_groups_vendor',         -- package_name
   'f',                         -- abstract_p
   NULL,                        -- type_extension_table
   NULL                         -- name_method
);

-- Primary Data Model
-- data model summary:
-- contact is the base organization or entity.
-- A user may have multiple entities, 1 or more of their own, and maybe some roles of others
-- Every vendor requires a contact record
-- Every customer requires a contact record
-- A contact can have multiple addresses
-- A user is mapped to their own personal contact record, and maybe others

--part of company_dates, company_details

-- See package accounts-contacts for qal_contact and the like.


 --part of company_dates, company_details
CREATE TABLE qal_customer (
       id                  integer default nextval('qal_id'),
       instance_id         integer,
       rev_id              integer default nextval('qal_id'),
       contact_id          integer,
       discount            numeric,
       tax_included        varchar(1) default '0',
       credit_limit        numeric default '0',
       -- terms aka company_licenses.lic_type
       terms               numeric default '0',
       -- terms_unit in tcl interval (days, weeks, month etc)
       terms_unit          varchar(20) default 'days',
       -- annual value at rate aka company_licenses.lic_value
       annual_value        numeric,
       --was customer_number
       customer_code     varchar(32),
       pricegroup_id       integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz
);

create index qal_customer_instance_id_idx on qal_customer (instance_id);
create index qal_customer_contact_id_idx on qal_customer (contact_id);
create index qal_customer_id_idx on qal_customer (id);
create index qal_customer_customer_code_idx on qal_customer (customer_code);
create index qal_customer_trashed_p_idx on qal_customer (trashed_p);

CREATE TABLE qal_vendor (
       id                  integer default nextval('qal_id'),
       instance_id         integer,
       rev_id              integer default nextval('qal_id'),
       contact_id          integer,
       terms               numeric default '0',
       terms_unit          varchar(20) default 'days',
       tax_included        varchar(1) default '0',
       -- was vendor_number
       vendor_code         varchar(32),
       gifi_accno          varchar(30),
       discount            numeric,
       credit_limit        numeric default 0,
       pricegroup_id       integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz,
       -- area_market can be address, city, state, country, worldwide, set of postal codes etc
       -- useful when marketing vendor goods indirectly
       area_market         text,
       -- policies help with buy decisions.
       purchase_policy     text,
       return_policy       text,
       -- price guarantee policy
       price_guar_policy   text,
       delivery_policy     text,
       installation_policy text
);

create index qal_vendor_instance_id_idx on qal_vendor (instance_id);
create index qal_vendor_contact_id_idx on qal_vendor (contact_id);
create index qal_vendor_id_idx on qal_vendor (id);
create index qal_vendor_vendor_code_idx on qal_vendor (vendor_code);
create index qal_vendor_trashed_p_idx on qal_vendor (trashed_p);

-- -- SIC, NAICS codes
-- -- code has been extended to allow use of UNSPC (and other) categorizations
-- -- references:
-- --  NAICS codes http://www.census.gov/epcd/naics/naicscod.txt
-- --  SIC crossreferences  http://www.census.gov/pub/epcd/www/naicstab.htm
-- --  ISIC and others  http://unstats.un.org/unsd/cr/
CREATE TABLE qal_sic (
       code        varchar(50),
       sic_type    varchar(30),
       description text
);

create index qal_sic_code_idx on qal_sic (code);
create index qal_sic_sic_type_idx on qal_sic (sic_type);

CREATE TABLE qal_customer_tax (
       instance_id  integer,
       customer_id  integer,
       chart_id     integer,
       created      timestamptz not null DEFAULT now(),
       created_by   integer,
       trashed_p    integer,
       trashed_by   integer,
       trashed_ts   timestamptz
);

create index qal_customer_tax_instance_id_idx on qal_customer_tax (instance_id);
create index qal_customer_tax_customer_id_idx on qal_customer_tax (customer_id);
create index qal_customer_tax_trashed_by_idx on qal_customer_tax (trashed_p);

CREATE TABLE qal_vendor_tax (
       instance_id  integer,
       vendor_id    integer,
       chart_id     integer,
       created      timestamptz not null DEFAULT now(),
       created_by   integer,
       trashed_p    integer,
       trashed_by   integer,
       trashed_ts   timestamptz
);

create index qal_vendor_tax_instance_id_idx on qal_vendor_tax (instance_id);
create index qal_vendor_tax_vendor_id_idx on qal_vendor_tax (vendor_id);
create index qal_vendor_tax_trashed_p_idx on qal_vendor_tax (trashed_p);
