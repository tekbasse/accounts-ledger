-- contacts-create.sql
--
-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id

-- this table needs split, moved into accounts-payroll package which will use the contacts package
-- create table qal_employee (
--   id integer default nextval('qal_id'),
--   login varchar(100),
--   name varchar(64),
--   address1 varchar(32),
--   address2 varchar(32),
--   city varchar(32),
--   state varchar(32),
--   zipcode varchar(10),
--   country varchar(32),
--   workphone varchar(20),
--   homephone varchar(20),
--   startdate date default current_date,
--   enddate date,
--   notes text,
--   role varchar(20),
--   sales bool default 'f',
--   email text,
--   ssn varchar(20),
--   iban varchar(34),
--   bic varchar(11),
--   managerid integer,
--   employeenumber varchar(32),
--   dob date
-- );

-- -- This table is to be *somehow* get integrated into contacts package
-- CREATE TABLE qal_vendor (
--   id integer default nextval('qal_id'),
--   name varchar(64),
--   address1 varchar(32),
--   address2 varchar(32),
--   city varchar(32),
--   state varchar(32),
--   zipcode varchar(10),
--   country varchar(32),
--   contact varchar(64),
--   phone varchar(20),
--   fax varchar(20),
--   email text,
--   notes text,
--   terms integer default 0,
--   taxincluded bool default 'f',
--   vendornumber varchar(32),
--   cc text,
--   bcc text,
--   gifi_accno varchar(30),
--   business_id integer,
--   taxnumber varchar(32),
--   sic_code varchar(15),
--   discount numeric,
--   creditlimit numeric default 0,
--   iban varchar(34),
--   bic varchar(11),
--   employee_id integer,
--   language_code varchar(6),
--   pricegroup_id integer,
--   curr char(3),
--   startdate date,
--   enddate date
-- );

-- -- SIC, NAICS codes
-- -- code has been extended to allow use of UNSPC (and other) categorizations
-- -- references:
-- --  NAICS codes http://www.census.gov/epcd/naics/naicscod.txt
-- --  SIC crossreferences  http://www.census.gov/pub/epcd/www/naicstab.htm
-- --  ISIC and others  http://unstats.un.org/unsd/cr/
-- CREATE TABLE qal_sic (
--   code varchar(15),
--   sictype varchar(3),
--   description text
-- );
-- 
-- -- This table is to be *somehow* get integrated into contacts package
-- CREATE TABLE qal_customer (
--   id integer default nextval('qal_id'),
--   name varchar(64),
--   address1 varchar(32),
--   address2 varchar(32),
--   city varchar(32),
--   state varchar(32),
--   zipcode varchar(10),
--   country varchar(32),
--   contact varchar(64),
--   phone varchar(20),
--   fax varchar(20),
--   email text,
--   notes text,
--   discount numeric,
--   taxincluded bool default 'f',
--   creditlimit numeric default 0,
--   terms integer default 0,
--   customernumber varchar(32),
--   cc text,
--   bcc text,
--   business_id integer,
--   taxnumber varchar(32),
--   sic_code varchar(6),
--   iban varchar(34),
--   bic varchar(11),
--   employee_id integer,
--   language_code varchar(6),
--   pricegroup_id integer,
--   curr char(3),
--   startdate date,
--   enddate date
-- );

-- 

-- CREATE TABLE qal_customertax (
--   customer_id integer,
--   chart_id integer
-- );
-- 

-- CREATE TABLE qal_vendortax (
--   vendor_id integer,
--   chart_id integer
-- );
-- 
-- 
-- create index qal_customer_id_key on qal_customer (id);
-- create index qal_customer_customernumber_key on qal_customer (customernumber);
-- create index qal_customer_name_key on qal_customer (lower(name));
-- create index qal_customer_contact_key on qal_customer (lower(contact));
-- create index qal_customer_customer_id_key on qal_customertax (customer_id);

-- create index qal_employee_id_key on qal_employee (id);
-- create unique index qal_employee_login_key on qal_employee (login);
-- create index qal_employee_name_key on qal_employee (lower(name));
-- 

-- create index qal_vendor_id_key on qal_vendor (id);
-- create index qal_vendor_name_key on qal_vendor (lower(name));
-- create index qal_vendor_vendornumber_key on qal_vendor (vendornumber);
-- create index qal_vendor_contact_key on qal_vendor (lower(contact));
-- create index qal_vendortax_vendor_id_key on qal_vendortax (vendor_id);
-- 
-- 

-- CREATE FUNCTION qal_del_customer() RETURNS OPAQUE AS '
-- begin
--   delete from qal_shipto where trans_id = old.id;
--   delete from qal_customertax where customer_id = old.id;
--   delete from qal_partscustomer where customer_id = old.id;
--   return NULL;
-- end;
-- ' language 'plpgsql';
-- -- end function

-- CREATE TRIGGER qal_del_customer AFTER DELETE ON qal_customer FOR EACH ROW EXECUTE PROCEDURE qal_del_customer();
-- -- end trigger

-- CREATE FUNCTION qal_del_vendor() RETURNS OPAQUE AS '
-- begin
--   delete from ecst_shipto where trans_id = old.id;
--   delete from qal_vendortax where vendor_id = old.id;
--   delete from ecca_partsvendor where vendor_id = old.id;
--   return NULL;
-- end;
-- ' language 'plpgsql';
-- -- end function

-- CREATE TRIGGER qal_del_vendor AFTER DELETE ON qal_vendor FOR EACH ROW EXECUTE PROCEDURE qal_del_vendor();
-- -- end trigger
-- 
-- --  following from ecommerce needs to be adapted to contacts etc.

--  with the shipto stuff moved to shipping-tracking package


-- create sequence ec_address_id_seq start 1; 
-- create view ec_address_id_sequence as select nextval('ec_address_id_seq') as nextval;
-- 
-- create table ec_addresses (
--         address_id      integer not null primary key,
--         user_id         integer not null references users,
--         address_type    varchar(20) not null,   -- e.g., billing
--         attn            varchar(100),
--         line1           varchar(100),
--         line2           varchar(100),
--         city            varchar(100),
--         -- state
--         -- Jerry, we'll need to creat the states table as part of this
--         usps_abbrev     char(2) references us_states(abbrev),
--         -- big enough to hold zip+4 with dash
--         zip_code        varchar(10),
--         phone           varchar(30),
--         -- for international addresses
--         -- Jerry, same for country_codes
--         country_code    char(2) references countries(iso),
--         -- this can be the province or region for an international address
--         full_state_name varchar(30),
--         -- D for day, E for evening
--         phone_time      varchar(10)
-- );
-- 
-- create index ec_addresses_by_user_idx on ec_addresses (user_id);
-- 
-- create sequence ec_user_class_id_seq start 1;
-- create view ec_user_class_id_sequence as select nextval('ec_user_class_id_seq') as nextval;
-- 
-- create table ec_user_classes (
--         user_class_id           integer not null primary key,
--         -- human-readable
--         user_class_name         varchar(200), -- e.g., student
--         last_modified           timestamptz not null,
--         last_modifying_user     integer not null references users,
--         modified_ip_address     varchar(20) not null
-- );
-- 
-- create table ec_user_classes_audit (
--         user_class_id           integer,
--         user_class_name         varchar(200), -- e.g., student
--         last_modified           timestamptz,
--         last_modifying_user     integer,
--         modified_ip_address     varchar(20),
--         delete_p                boolean default 'f'
-- );
-- 
-- create function ec_user_classes_audit_tr ()
-- returns opaque as '
-- begin
--         insert into ec_user_classes_audit (
--         user_class_id, user_class_name,
--         last_modified,
--         last_modifying_user, modified_ip_address
--         ) values (
--         old.user_class_id, old.user_class_name,
--         old.last_modified,
--         old.last_modifying_user, old.modified_ip_address      
--         );
-- 	return new;
-- end;' language 'plpgsql';
-- 
-- create trigger ec_user_classes_audit_tr
-- after update or delete on ec_user_classes
-- for each row execute procedure ec_user_classes_audit_tr ();
-- 

create table qar_ec_product_user_class_prices (
        product_id              integer not null references qci_ec_products,
        user_class_id           integer not null references qar_ec_user_classes,
        price                   numeric,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_id, user_class_id)
);

create index qar_ec_product_user_class_idx on qar_ec_product_user_class_prices(user_class_id);

-- qar_ec_product_user_class_prices_audit abbreviated as
-- qar_ec_product_u_c_prices_audit
create table qar_ec_product_u_c_prices_audit (
        product_id              integer,
        user_class_id           integer,
        price                   numeric,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function qar_ec_product_u_c_prices_audit_tr ()
returns opaque as '
begin
        insert into qar_ec_product_u_c_prices_audit (
        product_id, user_class_id,
        price,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id, old.user_class_id,
        old.price,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger qar_ec_product_u_c_prices_audit_tr
after update or delete on qar_ec_product_user_class_prices
for each row execute procedure qar_ec_product_u_c_prices_audit_tr ();




-- -- one row per customer-user; all the extra info that the ecommerce
-- -- system needs
-- 
-- create table ec_user_class_user_map (
--         user_id                 integer not null references users,
--         user_class_id           integer not null references ec_user_classes,
--                                     primary key (user_id, user_class_id),
--         user_class_approved_p   boolean,
--         last_modified           timestamptz not null,
--         last_modifying_user     integer not null references users,
--         modified_ip_address     varchar(20) not null
-- );
-- 
-- create index ec_user_class_user_map_idx on ec_user_class_user_map (user_class_id);
-- create index ec_user_class_user_map_idx2 on ec_user_class_user_map (user_class_approved_p);
-- 
-- create table ec_user_class_user_map_audit (
--         user_id                 integer,
--         user_class_id           integer,
--         user_class_approved_p   boolean,
--         last_modified           timestamptz,
--         last_modifying_user     integer,
--         modified_ip_address     varchar(20),
--         delete_p                boolean default 'f'
-- );
-- 
-- 
-- create function ec_user_class_user_audit_tr ()
-- returns opaque as '
-- begin
--         insert into ec_user_class_user_map_audit (
--         user_id, user_class_id, user_class_approved_p,
--         last_modified,
--         last_modifying_user, modified_ip_address
--         ) values (
--         old.user_id, old.user_class_id, old.user_class_approved_p,
--         old.last_modified,
--         old.last_modifying_user, old.modified_ip_address      
--         );
-- 	return new;
-- end;' language 'plpgsql';
-- 
-- create trigger ec_user_class_user_audit_tr
-- after update or delete on ec_user_class_user_map
-- for each row execute procedure ec_user_class_user_audit_tr ();
-- 
-- 
-- 
-- 
-- 
-- -- these tables are used if MultipleRetailersPerProductP is 1 in the
-- -- parameters .ini file
-- 
-- create sequence ec_retailer_seq start 1;
-- create view ec_retailer_sequence as select nextval('ec_retailer_seq') as nextval;
-- 
-- create table ec_retailers (
--         retailer_id             integer not null primary key,
--         retailer_name           varchar(300),
--         primary_contact_name    varchar(100),
--         secondary_contact_name  varchar(100),
--         primary_contact_info    varchar(4000),
--         secondary_contact_info  varchar(4000),
--         line1                   varchar(100),
--         line2                   varchar(100),
--         city                    varchar(100),
--         -- state
--         -- Jerry
--         usps_abbrev     	char(2) references us_states(abbrev),
--         -- big enough to hold zip+4 with dash
--         zip_code                varchar(10),
--         phone                   varchar(30),
--         fax                     varchar(30),
--         -- for international addresses
--         -- Jerry
--         country_code            char(2) references countries(iso),
--         --national, local, international
--         reach                   varchar(15) check (reach in ('national','local','international','regional','web')),
--         url                     varchar(200),
--         -- space-separated list of states in which tax must be collected
--         nexus_states            varchar(200),
--         financing_policy        varchar(4000),
--         return_policy           varchar(4000),
--         price_guarantee_policy  varchar(4000),
--         delivery_policy         varchar(4000),
--         installation_policy     varchar(4000),
--         last_modified           timestamptz not null,
--         last_modifying_user     integer not null references users,
--         modified_ip_address     varchar(20) not null
-- );
-- 
-- create table ec_retailers_audit (
--         retailer_id             integer,
--         retailer_name           varchar(300),
--         primary_contact_name    varchar(100),
--         secondary_contact_name  varchar(100),
--         primary_contact_info    varchar(4000),
--         secondary_contact_info  varchar(4000),
--         line1           	varchar(100),
--         line2           	varchar(100),
--         city            	varchar(100),
--         usps_abbrev     	char(2),
--         zip_code        	varchar(10),
--         phone           	varchar(30),
--         fax             	varchar(30),
--         country_code    	char(2),
--         reach           	varchar(15) check (reach in ('national','local','international','regional','web')),
--         url             	varchar(200),
--         nexus_states    	varchar(200),
--         financing_policy        varchar(4000),
--         return_policy           varchar(4000),
--         price_guarantee_policy  varchar(4000),
--         delivery_policy         varchar(4000),
--         installation_policy     varchar(4000),
--         last_modified           timestamptz,
--         last_modifying_user     integer,
--         modified_ip_address     varchar(20),
--         delete_p                boolean default 'f'
-- );
-- 
-- -- Jerry - I removed usps_abbrev and/or state here
-- create function ec_retailers_audit_tr ()
-- returns opaque as '
-- begin
--         insert into ec_retailers_audit (
--         retailer_id, retailer_name,
--         primary_contact_name, secondary_contact_name,
--         primary_contact_info, secondary_contact_info,
--         line1, line2,
--         city, usps_abbrev,
--         zip_code, phone,
--         fax, country_code,
--         reach, url,
--         nexus_states, financing_policy,
--         return_policy, price_guarantee_policy,
--         delivery_policy, installation_policy,
--         last_modified,
--         last_modifying_user, modified_ip_address
--         ) values (
--         old.retailer_id, old.retailer_name,
--         old.primary_contact_name, old.secondary_contact_name,
--         old.primary_contact_info, old.secondary_contact_info,
--         old.line1, old.line2,
--         old.city, old.usps_abbrev,
--         old.zip_code, old.phone,
--         old.fax, old.country_code,
--         old.reach, old.url,
--         old.nexus_states, old.financing_policy,
--         old.return_policy, old.price_guarantee_policy,
--         old.delivery_policy, old.installation_policy,
--         old.last_modified,
--         old.last_modifying_user, old.modified_ip_address      
--         );
-- 	return new;
-- end;' language 'plpgsql';
-- 
-- create trigger ec_retailers_audit_tr
-- after update or delete on ec_retailers
-- for each row execute procedure ec_retailers_audit_tr ();
-- 
-- create sequence ec_retailer_location_seq start 1;
-- create view ec_retailer_location_sequence as select nextval('ec_retailer_location_seq') as nextval;
-- 
-- create table ec_retailer_locations (
--         retailer_location_id    integer not null primary key,
--         retailer_id             integer not null references ec_retailers,
--         location_name           varchar(300),
--         primary_contact_name    varchar(100),
--         secondary_contact_name  varchar(100),
--         primary_contact_info    varchar(4000),
--         secondary_contact_info  varchar(4000),
--         line1                   varchar(100),
--         line2                   varchar(100),
--         city                    varchar(100),
--         -- state
--         -- Jerry
-- 	-- usps_abbrev reinstated by wtem@olywa.net
--         usps_abbrev     	char(2) references us_states(abbrev),
--         -- big enough 0to hold zip+4 with dash
--         zip_code                varchar(10),
--         phone                   varchar(30),
--         fax                     varchar(30),
--         -- for international addresses
--         -- Jerry
-- 	-- country_code reinstated by wtem@olywa.net
--         country_code            char(2) references countries(iso),
--         url                     varchar(200),
--         financing_policy        varchar(4000),
--         return_policy           varchar(4000),
--         price_guarantee_policy  varchar(4000),
--         delivery_policy         varchar(4000),
--         installation_policy     varchar(4000),
--         last_modified           timestamptz not null,
--         last_modifying_user     integer not null references users,
--         modified_ip_address     varchar(20) not null
-- );
-- 
-- create table ec_retailer_locations_audit (
--         retailer_location_id    integer,
--         retailer_id             integer,
--         location_name           varchar(300),
--         primary_contact_name    varchar(100),
--         secondary_contact_name  varchar(100),
--         primary_contact_info    varchar(4000),
--         secondary_contact_info  varchar(4000),
--         line1           	varchar(100),
--         line2           	varchar(100),
--         city            	varchar(100),
--         usps_abbrev     	char(2),
--         zip_code        	varchar(10),
--         phone           	varchar(30),
--         fax             	varchar(30),
--         country_code    	char(2),
--         url             	varchar(200),
--         financing_policy        varchar(4000),
--         return_policy           varchar(4000),
--         price_guarantee_policy  varchar(4000),
--         delivery_policy         varchar(4000),
--         installation_policy     varchar(4000),
--         last_modified           timestamptz,
--         last_modifying_user     integer,
--         modified_ip_address     varchar(20),
--         delete_p                boolean default 'f'
-- );
-- 
-- 
-- -- Jerry - I removed usps_abbrev and/or state here
-- create function ec_retailer_locations_audit_tr ()
-- returns opaque as '
-- begin
--         insert into ec_retailer_locations_audit (
--         retailer_location_id, retailer_id, location_name,
--         primary_contact_name, secondary_contact_name,
--         primary_contact_info, secondary_contact_info,
--         line1, line2,
--         city, usps_abbrev,
--         zip_code, phone,
--         fax, country_code,
--         url, financing_policy,
--         return_policy, price_guarantee_policy,
--         delivery_policy, installation_policy,
--         last_modified,
--         last_modifying_user, modified_ip_address
--         ) values (
--         old.retailer_location_id,
--         old.retailer_id, old.location_name,
--         old.primary_contact_name, old.secondary_contact_name,
--         old.primary_contact_info, old.secondary_contact_info,
--         old.line1, old.line2,
--         old.city, old.usps_abbrev,
--         old.zip_code, old.phone,
--         old.fax, old.country_code,
--         old.url, old.financing_policy,
--         old.return_policy, old.price_guarantee_policy,
--         old.delivery_policy, old.installation_policy,
--         old.last_modified,
--         old.last_modifying_user, old.modified_ip_address
--         );
-- 	return new;
-- end;' language 'plpgsql';
-- 
-- create trigger ec_retailer_locations_audit_tr
-- after update or delete on ec_retailer_locations
-- for each row execute procedure ec_retailer_locations_audit_tr ();
-- 
-- 
--
