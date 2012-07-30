-- accounts-ledger-drop.sql
--
-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id
--
drop function qal_del_exchangerate();
DROP FUNCTION qal_del_yearend();
DROP TRIGGER qal_del_yearend ON qal_gl;


DROP FUNCTION qal_del_department();

DROP TRIGGER qal_del_department ON qal_gl;

DROP FUNCTION qal_check_department();

DROP TRIGGER qal_check_department ON qal_gl;

DROP index qal_acc_trans_trans_id_key;
DROP index qal_acc_trans_chart_id_key;
DROP index qal_acc_trans_transdate_key;
DROP index qal_acc_trans_source_key;

--
DROP index qal_chart_id_key;
DROP index qal_chart_accno_key;
DROP index qal_chart_category_key;
DROP index qal_chart_link_key;
DROP index qal_chart_gifi_accno_key;
--
DROP index qal_exchangerate_ct_key;
--
DROP index qal_gl_id_key;
DROP index qal_gl_transdate_key;
DROP index qal_gl_reference_key;
DROP index qal_gl_description_key;
DROP index qal_gl_employee_id_key;

--
DROP index qal_status_trans_id_key;
--
DROP index qal_department_id_key;

--
DROP index qal_audittrail_trans_id_key;
--
DROP index qal_translation_trans_id_key;
--
DROP index qal_language_code_key;


DROP SEQUENCE qal_id;

DROP TABLE qal_template_accounts;

DROP TABLE qal_chart_templates;

DROP TABLE qal_template_defaults;

DROP TABLE qal_template_taxes;

DROP TABLE qal_gl;

DROP TABLE qal_chart;

DROP TABLE qal_defaults;

DROP TABLE qal_acc_trans;

DROP TABLE qal_tax;

DROP TABLE qal_exchangerate;

DROP TABLE qal_status;

DROP TABLE qal_department;

DROP TABLE qal_dpt_trans;

DROP TABLE qal_business;

DROP TABLE qal_yearend;
DROP TABLE qal_language;

DROP TABLE qal_audittrail;

DROP TABLE qal_translation;
