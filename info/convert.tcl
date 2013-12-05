# set the location of the accounts-ledger/catalog directory
# and the sql-ledger locale directory
# use full pathname
set qal_dir "/Users/head/openacs-4/packages/accounts-ledger"
set qal_cat_dir [file join $qal_dir catalog]
set qal_common_dir [file join $qal_dir sql common]

set sl_base_dir "/usr/local/src/sql-ledger"
set sl_loc_dir [file join $sl_base_dir locale]
set sl_chart_dir [file join $sl_base_dir sql]

# mapping key pairs to ease converting sql-ledger revisions
set dirmap(be_fr) "fr_BE"
set dirmap(be_nl) "nl_BE" 
set dirmap(br) "pt_BR" 
set dirmap(ca_en) "en_CA" 
set dirmap(ca_fr) "fr_CA" 
set dirmap(ch) "de_CH"
# not used: set dirmap(ch_utf) "de_CH"
set dirmap(cn_utf) "zh_HK" 
# not used: set dirmap(co) "" 
set dirmap(co_utf) "es_CO" 
set dirmap(ct) "ca_ES" 
# was ct_ES.. but ca is Catalan not ct

set dirmap(cz) "cz_CZ" 
# not used: set dirmap(de) "de_DE" 
set dirmap(de_utf) "de_DE" 
set dirmap(dk) "da_DK" 
set dirmap(ec) "es_EC" 
set dirmap(ee) "et_EE" 
set dirmap(eg) "ar_EG" 
set dirmap(en_GB) "en_GB" 
# not used: set dirmap(es) "es_ES" 
set dirmap(es_utf) "es_ES"
set dirmap(fi) "fi_FI" 
set dirmap(fr) "fr_FR" 
set dirmap(gr) "el_GR" 
set dirmap(hu) "hu_HU" 
set dirmap(id) "in_ID" 
# in_ID is actually ind_ID in OpenACS.. need to make adjustments to output..

set dirmap(is) "is_IS" 
set dirmap(it) "it_IT" 
set dirmap(lt) "lt_LT" 
set dirmap(lv) "lv_LV" 
set dirmap(mx) "es_MX" 
set dirmap(nb) "no_NO" 
set dirmap(nl) "nl_NL" 
set dirmap(pa) "es_PA" 
set dirmap(pl) "pl_PL" 
set dirmap(pt) "pt_PT" 
set dirmap(py) "es_PY" 
# not used: set dirmap(ru) "ru_RU" 
set dirmap(ru_utf) "ru_RU" 
set dirmap(se) "sv_SE" 
set dirmap(sv) "es_SV" 
set dirmap(tr) "tr_TR" 
# not used: set dirmap(tw_big5) "" 
set dirmap(tw_utf) "zh_TW" 
# not used: set dirmap(ua) "uk_UA" 
set dirmap(ua_utf) "uk_UA" 
set dirmap(ve) "es_VE" 
set dirmap(default) "en_US"

# set the chartname  to chart key mapping
set chartmap(Australia_General) "en_AU"
set chartmap(Austria) "de_AT"
set chartmap(Bahasa-Indonesia_Default) "in_ID"
set chartmap(Belgium) "fr_BE"
set chartmap(Brazil_General) "pt_BR"
set chartmap(Canada-English_General) "en_CA"
set chartmap(Canada-French_General) "fr_CA"
# not used: set chartmap(Colombia-PUC) ""
set chartmap(Colombia-utf8-PUC) "es_CO"
set chartmap(Czech-Republic) "cz_CZ"
set chartmap(Danish_Default) "da_DK"
set chartmap(Default) "en_US"
set chartmap(Dutch_Default) "nl_NL"
set chartmap(Dutch_Standard) "nl_NL_standard"
set chartmap(Egypt-UTF8) "ar_EG"
set chartmap(France) "fr_FR"
set chartmap(German-Sample) "de_DE"
set chartmap(Germany-DATEV-SKR03) "de_DE_DATEV"
set chartmap(Germany-SKR03) "de_DE_SKR03"
set chartmap(Hungary) "hu_HU"
set chartmap(Italy_General) "it_IT"
set chartmap(Italy_cc2424) "it_IT_cc2424"
set chartmap(Latvia) "lv_LV"
set chartmap(Norwegian_Default) "no_NO"
set chartmap(Paraguay) "es_PY"
set chartmap(Poland) "pl_PL"
set chartmap(Simplified-Chinese_Default-UTF8) "zh_HK"
# not used: set chartmap(Simplified-Chinese_Default) ""
# not used: set chartmap(Spain-ISO) ""
set chartmap(Spain-UTF8) "es_ES"
set chartmap(Swedish) "sv_SE"
set chartmap(Swiss-German) "de_CH"
set chartmap(Traditional-Chinese_Default-UTF8) "zh_TW"
# not used: set chartmap(Traditional-Chinese_Default) ""
set chartmap(UK_General) "en_GB"
set chartmap(US_General) "en_US"
set chartmap(US_Manufacturing) "en_US_mfg"
set chartmap(US_Service_Company) "en_US_service"
set chartmap(Venezuela_Default) "es_VE"


# we are converting different sources of text
# and am using some common routines

proc quote_xml_values { unquoted } {
    # xml standard requires certain characters to be
    # converted to entities when included in values:
    # &amp; &lt; &gt; &quot; &apos;

    # must be careful to not over quote any existing entities;    
    # expanding existing entities
    regsub -nocase -all -- {&lt;} $unquoted {<} unquoted
    regsub -nocase -all -- {&gt;} $unquoted {>} unquoted
    regsub -nocase -all -- {&quot;} $unquoted "\"" unquoted
    # following needs to be last
    regsub -all -- {&amp;} $unquoted {\&} unquoted

    # now make them again, amp needs to be first
    regsub -all -- {\&} $unquoted {\&amp;} quoted
    regsub -all -- "\"" $quoted {\&quot;} quoted
    regsub -all -- {>} $quoted {\&gt;} quoted
    regsub -all -- {<} $quoted {\&lt;} quoted
    return $quoted
}

# the 'all' phrases in the SL/locales directory
puts "converting the SL/locale/*/all data"
source convert-SL-locales.tcl

# the chart of accounts for the various locales
puts "converting the SL/sql/*-chart.sql data"
source convert-SL-charts.tcl

# the num2text functions for each of the locales
puts "converting the SL/locale/*/Num2text data"
source convert-SL-num2text.tcl

# close the xml file message tag
puts "closing xml file catalog_message tags"
source convert-close-tags.tcl

puts "done."
