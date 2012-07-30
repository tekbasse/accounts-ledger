\copy qal_template_accounts from '[acs_root_dir]/packages/accounts-ledger/sql/common/qal_template_accounts.dat' using delimiters ',' with null as ''
\copy qal_chart_templates from '[acs_root_dir]/packages/accounts-ledger/sql/common/qal_chart_templates.dat' using delimiters ',' with null as ''
\copy qal_template_defaults from '[acs_root_dir]/packages/accounts-ledger/sql/common/qal_template_defaults.dat' using delimiters ',' with null as ''
\copy qal_template_taxes from '[acs_root_dir]/packages/accounts-ledger/sql/common/qal_template_taxes.dat' using delimiters ',' with null as ''
