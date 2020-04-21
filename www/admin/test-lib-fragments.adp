<master>

  <p>Equalize doesn't work by default in OpenACS due to security concerns. It's not needed when background is same color anyway, so leaving out.</p>
  

    <include src="/packages/accounts-ledger/www/page-runner-block-1col" content_c1=@content_c1;noquote@>
    
    <include src="/packages/accounts-ledger/www/page-runner-block-3col" content_c1=@content_c2;noquote@ content_c3=@content_c3;noquote@ content_c2="Logo and address here!">
    
    
    
    <include src="/packages/accounts-ledger/www/page-runner-block-2col" content_c1="left content for 2 column block" content_c2="right content for 2 column block">
    <hr>
    <include src="/packages/accounts-ledger/www/page-runner-block-1col" content_c1=@content_c4;noquote@>
    
    <include src="/packages/accounts-ledger/www/page-runner-block-5col" content_c5=@content_c5;noquote@ content_c4=@content_c6;noquote@ content_c3=@content_c7;noquote@ content_c2="cell2" content_c1="cell1">

      <div style="display:none;">
        <!-- diagnostic information -->
qf_fields_ordered_list: '@qf_fields_ordered_list@' 

@content_c@
</div>
