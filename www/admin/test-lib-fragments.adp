<master>

  <p>Equalize doesn't work by default in OpenACS due to security concerns. It's not needed when background is same color anyway, so leaving out.</p>
  

    <include src="/packages/accounts-ledger/www/page-runner-block-1col" content_c1=@content_c1;noquote@/>
    
    <include src="/packages/accounts-ledger/www/page-runner-block-3col" content_c2=@content_c2;noquote@/>
    
    
    <include src="/packages/accounts-ledger/www/page-runner-block-3col" content_c2=@content_c3;noquote@/>
    
    <include src="/packages/accounts-ledger/www/page-runner-block-2col" content_c1="left content for 2 column footer block" content_c2=@content_c4;noquote@>
    <hr>
    
    <include src="/packages/accounts-ledger/www/page-runner-block-5col" content_c1="cell1" content_c2="cell2" content_c3="cell3" content_c4="cell4" content_c5="cell5"/>

  
