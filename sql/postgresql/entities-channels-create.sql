-- contacts-create.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id

-- data model summary:
-- contact is the base organization or entity.
-- A user may have multiple entities, 1 or more of their own, and maybe some roles of others
-- Every vendor requires a contact record
-- Every customer requires a contact record
-- A contact can have multiple addresses
-- A user is mapped to their own personal contact record, and maybe others

--part of company_dates, company_details
CREATE TABLE qal_contact (
       -- party_id ie object_id. This is to avoid id collision with inter-package use cases,
       -- such as with customer-service package and this one.
       -- In general, it is a good idea to link an object_id to each contact anyway,
       -- in case conventional openacs group permissions are used.
       -- set id  application_group::new -package_id $instance_id -group_name $label
       id                  integer unique not null,
       -- revision_id. Updates create new record and trash old
       -- same id, new rev_id 
       rev_id              integer default nextval('qal_id'),
       instance_id         integer not null,
       -- for some aggregate reporting, a parent_id may be useful. 
       -- However, each contact is considered a separate entity for permissions etc.
       parent_id           integer,
       -- label is expected to be unique to an instance_id
       label               varchar(40),
       name                varchar(80),
       -- preferred qal_other_address_map.addrs_id
       -- is based on sort_order
       -- lowest number first.
       street_addrs_id     integer,
       mailing_addrs_id    integer,
       billing_addrs_id    integer,
       -- business_id is qal_vendor.vendor_id
       vendor_id           integer,
       customer_id         integer,
       taxnumber           varchar(32),
       sic_code            varchar(15),
       -- country code using ISO 3166-1 alpha-2 - char(2)
       -- check digits - char(2)
       -- account number varchar(30)
       -- no spaces
       -- yet expressed in groups of four characters separated by a space
       iban                varchar(34),
       -- business identifier code aka swift etc
       -- institution code char(4)
       -- iso 3166-1 alpha-2 country code char(2)
       -- location code char(2)
       -- branch code char(3), optional.
       -- logical terminal code char(1) not part of formal bic. 
       bic                 varchar(12),
       language_code       varchar(6),
       currency            varchar(3),
       -- default is from user_preferences.timezone
       timezone            varchar(100),
       time_start          timestamptz,
       time_end            timestamptz,
       url                 varchar(200),
       user_id             integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz,
       notes               text
);

create index qal_contact_id_idx on qal_contact (id);
create index qal_contact_instance_id_idx on qal_contact (instance_id);
create index qal_contact_trashed_p_idx on qal_contact (trashed_p);
create index qal_contact_rev_id_idx on qal_contact (rev_id);
create index qal_contact_label_idx on qal_contact (label);

-- was qal_contact_group ( or contact_group in SL)
-- mainly gets used in packages that depend on accounts-ledger
-- Deprecated. See qc_user_ids_of_contact_id, and qc_user_role_add
CREATE TABLE qal_contact_user_map (
       instance_id         integer,
       contact_id          integer,
       user_id             integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz
);

create index qal_contact_user_map_instance_id_idx on qal_contact_user_map (instance_id);
create index qal_contact_user_map_contact_id_idx on qal_contact_user_map (contact_id);
create index qal_contact_user_map_user_id_idx on qal_contact_user_map (user_id);
create index qal_contact_user_map_trashed_p_idx on qal_contact_user_map (trashed_p);

-- Plenty of cases do not fit traditional norms. Allow for more cases with this model.
CREATE TABLE qal_other_address_map (
       contact_id          integer,
       instance_id         integer,
       -- unique id of a means of contact
       -- If record_type is address, address_id is same as qal_address.id
       addrs_id            integer default nextval('qal_id'),
       -- address, other..
       -- if record_type is not address, it may be YIM,AIM etc --
       record_type         varchar(30),
       -- If this is an address, this references qal_address.id
       -- If null, this is a contact method (skype,aim,yim,jabber etc)
       -- Address_id doubles as rev_id integer default nextval('qal_id'),
       address_id          integer,
       sort_order          integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz,
       -- if record_type is not address, refer to account_name
       -- YIM username etc. or maybe runner..
       -- text allows for anything
       account_name        text,
       notes               text
);

create index qal_other_address_map_contact_id_idx on qal_other_address_map (contact_id);
create index qal_other_address_map_instance_id_idx on qal_other_address_map (instance_id);
create index qal_other_address_map_record_type_idx on qal_other_address_map (record_type);
create index qal_other_address_map_address_id_idx on qal_other_address_map (address_id);
create index qal_other_address_map_trashed_p_idx on qal_other_address_map (trashed_p);

CREATE TABLE qal_address (
        id                 integer default nextval('qal_id'),
        instance_id        integer,
        rev_id             integer default nextval('qal_id'),
        -- e.g., billing, shipping
        address_type       varchar(20) not null default 'street',  
        address0           varchar(40),
        address1           varchar(40),
        address2           varchar(40),
        city               varchar(40),
        state              varchar(32),
        postal_code        varchar(20),
        -- references countries(iso)
        country_code       varchar(3),
        attn               varchar(64),
        phone              varchar(30),
        phone_time         varchar(10),
        fax                varchar(30),
        -- text type allows multiple entries
        email              text,
        cc                 text,
        bcc                text
);

create index qal_address_instance_id_idx on qal_address (instance_id);
create index qal_address_id_idx on qal_address (id);
create index qal_address_address_type_idx on qal_address (address_type);


 -- a contact manager style should have an additional table and map for
 -- multiple with:
 -- contact_id 
 -- contact_method (skype etc)
 -- userid
 -- notes 

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
       terms               integer default 0,
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
