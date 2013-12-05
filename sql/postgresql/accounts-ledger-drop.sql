-- accounts-ledger-drop.sql

-- @author Benjamin Brink
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991




drop index qal_translation_trans_id_idx;

DROP TABLE qal_translation;

drop index qal_language_code_idx;

DROP TABLE qal_language;

DROP TABLE qal_yearend;

DROP TABLE qal_discounts; 

DROP TABLE qal_dept_trans_map; 

drop index qal_department_id_idx;

DROP TABLE qal_department;

drop index qal_status_trans_id_idx;

DROP TABLE qal_status;
drop index qal_exchangerate_ct_idx;

DROP TABLE qal_exchangerate;

DROP TABLE qal_tax; 

drop index qal_acc_trans_source_idx;
drop index qal_acc_trans_transdate_idx;
drop index qal_acc_trans_chart_id_idx;
drop index qal_acc_trans_trans_id_idx;

DROP TABLE qal_acc_trans;

DROP TABLE qal_defaults;

drop index qal_chart_gifi_accno_idx;
drop index qal_chart_link_idx;
drop index qal_chart_category_idx;
drop index qal_chart_accno_idx;
drop index qal_chart_id_idx;

DROP TABLE qal_chart;

drop index qal_gl_employee_id_idx;
drop index qal_gl_description_idx;
drop index qal_gl_reference_idx;
drop index qal_gl_transdate_idx;
drop index qal_gl_id_idx;

DROP TABLE qal_gl;

DROP TABLE qal_template_taxes; 

DROP TABLE qal_template_defaults; 

DROP TABLE qal_chart_templates;

DROP TABLE qal_template_accounts;

DROP SEQUENCE qal_id;

