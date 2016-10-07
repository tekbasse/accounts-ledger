-- contacts-create.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id

--part of company_dates, company_details
CREATE TABLE qal_contact (
       id                  integer unique not null,
       -- revision_id. Updates create new record and trash old
       -- same id, new rev_id 
       rev_id              integer,
       instance_id         integer not null,
       parent_id           integer,
       label               varchar(40),
       name                varchar(80),
       street_addrs_id     integer,
       mailing_addrs_id    integer,
       billing_addrs_id    integer,
       business_id         integer,
       taxnumber           varchar(32),
       sic_code            varchar(15),
       iban                varchar(34),
       bic                 varchar(11),
       language_code       varchar(6),
       currency            varchar(3),
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
       
CREATE TABLE qal_address (
        id                 integer default nextval('qal_id'),
        instance_id        integer,
        rev_id             integer,
        sort_order         integer,
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
        bcc                text,
        created            timestamptz not null DEFAULT now(),
        created_by         integer,
        trashed_p          integer,
        trashed_by         integer,
        trashed_ts         timestamptz
 );

create index qal_address_instance_id_idx on qal_address (instance_id);
create index qal_address_id_idx on qal_address (id);
create index qal_address_address_type_idx on qal_address (address_type);
create index qal_trashed_p_idx on qal_address (trashed_p);

 --part of company_dates, company_details
CREATE TABLE qal_customer (
       id                  integer default nextval('qal_id'),
       instance_id         integer,
       rev_id              integer,
       contact_id          integer,
       discount            numeric,
       tax_included        varchar(1) default '0',
       credit_limit        numeric default '0',
       -- terms aka company_licenses.lic_type
       terms               numeric default '0',
       terms_unit          varchar(20) default 'days',
       -- annual value at rate aka company_licenses.lic_value
       annual_value        numeric,
       -- terms_unit in tcl interval (days, weeks, month etc)
       customer_number     varchar(32),
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
create index qal_customer_customer_number_idx on qal_customer (customer_number);
create index qal_customer_trashed_p_idx on qal_customer (trashed_p);

CREATE TABLE qal_vendor (
       id                  integer default nextval('qal_id'),
       instance_id         integer,
       rev_id              integer,
       contact_id          integer,
       terms               integer default 0,
       tax_included        varchar(1) default '0',
       vendor_number       varchar(32),
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
create index qal_vendor_vendor_number_idx on qal_vendor (vendor_number);
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
create index qal_customer_tax_trashed_by_idx on qal_customer_trax (trashed_p);

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
