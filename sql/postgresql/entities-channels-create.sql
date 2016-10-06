-- contacts-create.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id

 --part of company_dates, company_details
 CREATE TABLE qal_contact (
        id                 integer unique not null,
        instance_id        integer not null,
        -- same as company_summary.parent_company=integer
        parent_id          integer,
        label              varchar(40),
        name               varchar(80),
        street_address_id  integer,
        mailing_address_id integer,
        billing_address_id integer,
        business_id        integer,
        taxnumber          varchar(32),
        sic_code           varchar(15),
        iban               varchar(34),
        bic                varchar(11),
        language_code      varchar(6),
        currency           varchar(3),
        time_start         timestamptz,
        time_end           timestamptz,
        url                varchar(200),
        notes              text
 );

 CREATE TABLE qal_contact_address_map (
        instance_id       integer,
        contact_id        integer,
        address_id        integer,
        trashed_p         integer
);

CREATE TABLE qal_contact_use_map (
       instance_id        integer,
       contact_id         integer,
       user_id            integer,
       created            timestamptz not null DEFAULT now(),
       created_by         integer,
       trashed_p          integer,
       trashed_by         integer,
       trashed_ts         timestamptz
);
       
 create table qal_address (
        id                integer default nextval('qal_id'),
        instance_id       integer,
        address_type      varchar(20) not null default 'street',   
        -- e.g., billing, shipping
        first_name        varchar(64),
        last_name         varchar(64),
        address1          varchar(40),
        address2          varchar(40),
        city              varchar(40),
        state             varchar(32),
        postalcode        varchar(20),
        country_code      varchar(3),
        -- references countries(iso)
        attn              varchar(64),
        phone             varchar(30),
        phone_time        varchar(10),
        fax               varchar(30),
        user_id           integer,
        -- text type allows multiple entries
        email             text,
        cc                text,
        bcc               text
 );

 --part of company_dates, company_details
 CREATE TABLE qal_customer (
        id              integer default nextval('qal_id'),
        instance_id     integer,
        contact_id      integer,
        discount        numeric,
        tax_included    varchar(1) default '0',
        credit_limit    numeric default 0,
        -- terms aka company_licenses.lic_type
        terms           numeric default '0',
        terms_unit      varchar(20) default 'days',
	-- annual value at rate aka company_licenses.lic_value
        annual_value    numeric,
        -- terms_unit in tcl interval (days, weeks, month etc)
        customer_number varchar(32),
        pricegroup_id   integer
 );


 CREATE TABLE qal_vendor (
        id                     integer default nextval('qal_id'),
	instance_id	       integer,
        contact_id             integer,
        terms                  integer default 0,
        tax_included           varchar(1) default '0',
        vendor_number          varchar(32),
        gifi_accno             varchar(30),
        discount               numeric,
        credit_limit           numeric default 0,
        pricegroup_id          integer,
        area_market            varchar(30),
        -- area_market can be address, city, state, country, worldwide
        -- useful when marketing vendor goods indirectly
        purchase_policy        text,
        -- policies help with buy decisions.
        return_policy          text,
        price_guarantee_policy text,
        delivery_policy        text,
        installation_policy    text
 );

-- -- SIC, NAICS codes
-- -- code has been extended to allow use of UNSPC (and other) categorizations
-- -- references:
-- --  NAICS codes http://www.census.gov/epcd/naics/naicscod.txt
-- --  SIC crossreferences  http://www.census.gov/pub/epcd/www/naicstab.htm
-- --  ISIC and others  http://unstats.un.org/unsd/cr/
 CREATE TABLE qal_sic (
        code        varchar(50),
        sic_type    varchar(9),
        description text
 );

 CREATE TABLE qal_customer_tax (
 instance_id  integer,
  customer_id integer,
  chart_id    integer      
 );


 CREATE TABLE qal_vendor_tax (
  instance_id integer,
  vendor_id integer,
  chart_id  integer
 );

-- mainly gets used in packages that depend on accounts-ledger
CREATE TABLE qal_contact_group (
  instance_id integer,
  contact_id integer,
  user_id integer
);
