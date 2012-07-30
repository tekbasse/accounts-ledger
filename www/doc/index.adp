<master>
  <property name="title">@package_instance_name@</property>
 <p>
  General Ledger provides services to other packages and provides a basic UI for directly managing a ledger and accounts.
 </p>
<h3>
 Features
</h3>
<h4>Converted:</h4>
<ul><li>
Preliminary data model for Postgresql including preloading chart templates and language translations when installing.
</li><li>
Num2text in SL, lc_number_to_text in accounts-payables package
</li></ul>
<h4>Plan summary</h4>
 <p>
Basic general ledger posting via web and service (also callback?), and editing chart templates.  One ledger per package instance.  See sql-ledger's <a href="http://sql-ledger.org/cgi-bin/nav.pl?page=features.html&title=Features" target="_blank">features</a> and <a href="http://sql-ledger.org/cgi-bin/nav.pl?page=news.html&title=What's%20New" target="_blank">What's new</a> pages.
 </p>
<h3>
notes</h3>
<pre>
sql-ledger        package-key  table name

&lt;table_name&gt;        qal_&lt;table_name&gt;


</pre><p>
Need to add package_key to data model.
</p><h3>
porting notes and guidelines
</h3><p>
The locale data has been extracted using a custom program located in the accounts-ledger/info directory of this package. Configuration data is set in convert.tcl. Be sure to remove xml language files in accounts-ledger/catalog/ before running the program.
</p><p>
Any functions dependent on either AP or AR data are moved to those packages. When something is dependent on two or more accounting packages, it is moved into the "full accounting features" accounts-desk package.
</p>
<p>
Each package has a set of Model-View-Control features and services.  Most any of these packages should provide a basic level of features without requiring other packages. Optional (integrated) features are built into the packages where appropriate.
</p><h3>
Table of "critical path" package dependencies
</h3><table border="1" cellspacing="0" cellpadding="3">
<tr>
<th>package-key</th><th>depends on</th>
</tr><tr>
<td>accounts-ledger </td><td>contacts, inventory-control</td>
</tr><tr>
<td>accounts-payables      </td><td>accounts-ledger</td>
</tr><tr>
<td>accounts-receivables  </td><td>accounts-ledger</td>
</tr><tr>
<td>accounts-desk         </td><td>accounts-payables, accounts-receivables, accounts-payroll</td>
</tr><tr>
<td>ref-gifi              </td><td>none, integrates with accounts-ledger</td>
</tr><tr>
<td>ref-unspsc            </td><td>none, integrates with categories</td>
</tr><tr>
<td>accounts-payroll      </td><td>accounts-ledger</td>
</tr><tr>
<td>inventory-control     </td><td>none</td>
</tr><tr>
<td>online-catalog        </td><td>none</td>
</tr><tr>
<td>shipping-tracking</td><td>accounts-ledger</td>
</tr></table>
<p>(see <a href="http://openacs.org/xowiki/pages/en/ecommerce-g2">ecommerce G2</a>)
</p>
<h3>
functions and procedures
</h3><p>
lc_number_to_text proc is made from the the SL Num2text procedure which has localized cases in the locale directories, and the default Num2text.pm in sql-ledger/SL/
</p>
<h3>
SQL
</h3><p>
The Oracle SQL will be added after the PG SQL has settled a bit.
</p><p>Some of the SQL has been changed to the OpenACS standards. See http://openacs.org/doc/current/eng-standards-plsql.html and http://openacs.org/wiki
</p><pre>
for Postgresql:

INT changed to INTEGER
some of the TEXT types were changed to VARCHAR so that they get indexed
FLOAT changed to NUMERIC
</pre>
<p>These parameters need to be put into their respective packages</p>
<pre>
   -- this is a 1-row table
   -- it contains all settings that the admin can change from the admin pages
   -- most of the configuration is done using the parameters .ini file
   -- wtem@olywa.net 03-10-2001
   -- the following two tables probably need an additional column to support subsites
   -- in which case it will have multiple rows, one for each instance of ecommerce
   -- since these are really parameters for the instance of ecommerce, 
   -- it might be better to move them to ad_parameters
   create table ec_admin_settings (
           -- this is here just so that the insert statement (a page or
           -- so down) can't be executed twice
           admin_setting_id                integer not null primary key,   
           -- the following columns are related to shipping costs
           base_shipping_cost              numeric,
           default_shipping_per_item       numeric,
           weight_shipping_cost            numeric,
           add_exp_base_shipping_cost      numeric,
           add_exp_amount_per_item         numeric,
           add_exp_amount_by_weight        numeric,
           -- default template to use if the product isn't assigned to one
           -- (until the admin changes it, it will be 1, which will be
           -- the preloaded template)
           default_template        	integer default 1 not null 
   					    references ec_templates,
           last_modified           	timestamptz not null,
           last_modifying_user     	integer not null references users,
           modified_ip_address     	varchar(20) not null
   );

-- create table ec_admin_settings_audit (
--         admin_setting_id                integer,
--         base_shipping_cost              numeric,
--         default_shipping_per_item       numeric,
--         weight_shipping_cost            numeric,
--         add_exp_base_shipping_cost      numeric,
--         add_exp_amount_per_item         numeric,
--         add_exp_amount_by_weight        numeric,
--         default_template        	integer,
--         last_modified           	timestamptz,
--         last_modifying_user     	integer,
--         modified_ip_address     	varchar(20),
--         delete_p                	boolean default 'f'
-- );
-- 
-- create function ec_admin_settings_audit_tr ()
-- returns opaque as '
-- begin
--         insert into ec_admin_settings_audit (
--         admin_setting_id, base_shipping_cost, default_shipping_per_item,
--         weight_shipping_cost, add_exp_base_shipping_cost,
--         add_exp_amount_per_item, add_exp_amount_by_weight,
--         default_template,
--         last_modified,
--         last_modifying_user, modified_ip_address
--         ) values (
--         old.admin_setting_id, old.base_shipping_cost, 
-- 	old.default_shipping_per_item,
--         old.weight_shipping_cost, old.add_exp_base_shipping_cost,
--         old.add_exp_amount_per_item, old.add_exp_amount_by_weight,
--         old.default_template,
--         old.last_modified,
--         old.last_modifying_user, old.modified_ip_address      
--         );
-- 	return new;
-- end;' language 'plpgsql';
-- 
-- create trigger ec_admin_settings_audit_tr
-- after update or delete on ec_admin_settings
-- for each row execute procedure ec_admin_settings_audit_tr ();
-- 
-- -- this is where the ec_amdin_settings insert was
-- 
-- 
-- -- put one row into ec_admin_settings so that I don't have to use 0or1row
-- insert into ec_admin_settings (
--         admin_setting_id,
--         default_template,
--         last_modified,
--         last_modifying_user,
--         modified_ip_address
--         ) values (
--         1,
--         1,
--         now(), (select grantee_id
--                     from acs_permissions
--                    where object_id = acs__magic_object_id('security_context_root')
--                      and privilege = 'admin'
--                      limit 1),
--         'none');
-- 
-- 
</pre>
