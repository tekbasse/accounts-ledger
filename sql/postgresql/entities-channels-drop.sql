-- accounts-contacts-drop.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991

select acs_object_type__drop_type('qal_grps_customer','f');
drop index qal_customer_object_id_map_customer_id_idx;
drop index qal_customer_object_id_map_instance_id_idx;

DROP TABLE qal_customer_object_id_map;

select acs_object_type__drop_type('qal_grps_vendor','f');
drop index qal_vendor_object_id_map_vendor_id_idx;
drop index qal_vendor_object_id_map_instance_id_idx;

DROP TABLE qal_vendor_object_id_map;

-- App data model

drop index qal_vendor_tax_trashed_p_idx;
drop index qal_vendor_tax_vendor_id_idx;
drop index qal_vendor_tax_instance_id_idx;

DROP TABLE qal_vendor_tax;

drop index qal_customer_tax_trashed_by_idx;
drop index qal_customer_tax_customer_id_idx;
drop index qal_customer_tax_instance_id_idx;

DROP TABLE qal_customer_tax;

drop index qal_sic_sic_type_idx;
drop index qal_sic_code_idx;

DROP TABLE qal_sic;

drop index qal_vendor_trashed_p_idx;
drop index qal_vendor_vendor_code_idx;
drop index qal_vendor_id_idx;
drop index qal_vendor_contact_id_idx;
drop index qal_vendor_instance_id_idx;

DROP TABLE qal_vendor;

drop index qal_customer_trashed_p_idx;
drop index qal_customer_customer_code_idx;
drop index qal_customer_id_idx;
drop index qal_customer_contact_id_idx;
drop index qal_customer_instance_id_idx;

DROP TABLE qal_customer;


