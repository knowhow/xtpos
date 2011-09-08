CREATE OR REPLACE FUNCTION xtpos.cashRegClose(integer, integer, numeric, bpchar, numeric, bpchar, text) RETURNS INTEGER AS $$
DECLARE
  pTerminalId		ALIAS FOR $1;
  pBankAccntId		ALIAS FOR $2;
  _transferAmt		NUMERIC := COALESCE($3,0);
  pTransferDir		ALIAS FOR $4;
  _adjustAmt		NUMERIC := COALESCE($5,0);
  pAdjustDir		ALIAS FOR $6;
  pNotes		ALIAS FOR $7;
  _baglaccntid		INTEGER;
  _chkamt		NUMERIC;
  _cshamt     		NUMERIC;
  _ccBaglaccntid	INTEGER;
  _ccOrderDesc		TEXT;
  _journal		INTEGER;
  _noteSales		TEXT;
  _noteClose		TEXT;
  _rec	 		RECORD;
  _sale			RECORD;
  _regdetailid		INTEGER;
  _seqRev  		INTEGER;
  _seqCls		INTEGER;
  _taxBaseValue		NUMERIC;
  _test			INTEGER := 0;
  _cohistid		INTEGER;
  
BEGIN  
  -- Validate
  IF (_transferAmt < 0 OR _adjustAmt < 0) THEN
    RAISE EXCEPTION 'Negative amounts may not be entered';
  ELSIF (pTransferDir NOT IN ('I','O') OR pAdjustDir NOT IN ('I','O')) THEN
    RAISE EXCEPTION 'Invalid amount direction.  Valid directions are "I" (In) and "O" (Out)'; 
  
  -- Fetch set up data
  ELSE
    SELECT reghist_id, reghist_asset_accnt_id, reghist_adjust_accnt_id,
      reghist_chkclr_accnt_id, regdetail_endbal, terminal_number INTO _rec
    FROM xtpos.reghist
      JOIN xtpos.regdetail ON (reghist_id=regdetail_reghist_id)
      JOIN xtpos.terminal ON (reghist_terminal_id=terminal_id)
    WHERE ((reghist_terminal_id=pTerminalId)
     AND (reghist_open))
    ORDER BY regdetail_time DESC
    LIMIT 1;
    
    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Terminal register is not open';
    END IF;
  END IF;

  -- Fetch Bank Account G/L Account Id
  IF (pBankAccntId IS NOT NULL) THEN
    SELECT bankaccnt_accnt_id INTO _baglaccntid
    FROM xtpos.rtlsiteterm
      JOIN xtpos.rtlsite ON (rtlsite_id=rtlsiteterm_rtlsite_id)
      JOIN xtpos.rtlsitebnkacct ON (rtlsite_id=rtlsitebnkacct_rtlsite_id)
      JOIN bankaccnt ON (rtlsitebnkacct_bankaccnt_id=bankaccnt_id)
    WHERE ((bankaccnt_id=pBankAccntId)
     AND (rtlsiteterm_terminal_id=pTerminalId));

    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Bank Account not found for this retail site';
    END IF;
  ELSIF (pBankAccntId IS NULL AND _transferamt > 0) THEN
    RAISE EXCEPTION 'Bank account must be provided to process transfer';
  END IF;

  -- Determine sense
  IF (pAdjustDir = 'O') THEN
    _adjustAmt := _adjustAmt * -1;
  END IF;

  IF (pTransferDir = 'O') THEN
    _transferAmt := _transferAmt * -1;
  END IF;

  --  Get Credit card gl account.  When 7606 implemented, we'll
  --  Have to get an account for each credit card type
  SELECT bankaccnt_accnt_id INTO _ccBaglaccntid
  FROM bankaccnt
  WHERE (bankaccnt_id=fetchmetricvalue('CCDefaultBank')::INTEGER);

  -- Set some variables for G/L processing
  _journal	:= fetchJournalNumber('C/R');
  _seqRev 	:= fetchGLSequence();
  _seqCls	:= fetchGLSequence();
  _noteSales 	:= 'Sales posting for terminal ' || _rec.terminal_number;
  _noteClose	:= 'Close terminal ' || _rec.terminal_number;

  -- Post Sales
  FOR _sale IN
    SELECT
      salehead_cust_id, salehead_time,salehead_number, salehead_cashamt,
      salehead_checknumber, salehead_salesrep_id,
      saleitem_id, saleitem_unitprice, saleitem_qty, saleitem_taxtype_id,
      saleitem_itemsite_id, round(saleitem_unitprice * saleitem_qty,2) AS sale_amount,
      findSalesAccnt(saleitem_itemsite_id, 'IS', salehead_cust_id) AS sales_accnt_id,
      COALESCE(invhist_unitcost,0) AS unitcost,
      cust_name, addr_line1, addr_line2, addr_line3,
      addr_city, addr_state, addr_postalcode,
      COALESCE(salesrep_commission,0) AS commission
    FROM xtpos.reghist
      JOIN xtpos.salehead ON (reghist_id=salehead_reghist_id)
      JOIN xtpos.saleitem ON (salehead_id=saleitem_salehead_id)
      LEFT OUTER JOIN invhist ON (saleitem_invhist_id=invhist_id)
      LEFT OUTER JOIN custinfo ON (salehead_cust_id=cust_id)
      LEFT OUTER JOIN cntct ON (cust_cntct_id=cntct_id)
      LEFT OUTER JOIN addr ON (cntct_addr_id=addr_id)
      LEFT OUTER JOIN salesrep ON (salehead_salesrep_id=salesrep_id)
    WHERE (salehead_reghist_id=_rec.reghist_id)
  LOOP
    IF (_test >= 0) THEN

      -- Credit revenue
      IF (_sale.sale_amount > 0) THEN
        SELECT insertIntoGLSeries( _seqRev, 'S/O', 'RS', _rec.terminal_number, 
	    salesaccnt_sales_accnt_id, _sale.sale_amount, 
	    current_date, _noteSales) INTO _test
	FROM salesaccnt
	WHERE (salesaccnt_id=_sale.sales_accnt_id);
      END IF;

      -- Credit tax accounts
      PERFORM addTaxToGLSeries(_seqRev, 
	   'S/O', 'RS', _rec.terminal_number,
	   basecurrid(),
	   current_date, current_date,
	   'saleitemtax', _sale.saleitem_id, _noteSales);

      UPDATE xtpos.saleitemtax
      SET taxhist_journalnumber = _journal
      WHERE (taxhist_parent_id=_sale.saleitem_id);

      -- Record sales history
      SELECT nextval('cohist_cohist_id_seq') INTO _cohistid;
      INSERT INTO cohist
      ( cohist_id,cohist_cust_id, cohist_itemsite_id, 
        cohist_shipdate, cohist_shipvia, cohist_invcdate,
        cohist_ordernumber, cohist_orderdate, cohist_doctype,
        cohist_qtyshipped, cohist_unitprice, cohist_unitcost,
        cohist_salesrep_id, cohist_commission, cohist_commissionpaid,
        cohist_billtoname, cohist_billtoaddress1,
        cohist_billtoaddress2, cohist_billtoaddress3,
        cohist_billtocity, cohist_billtostate, cohist_billtozip,
        cohist_sequence, cohist_taxtype_id)
      VALUES
      ( _cohistid,_sale.salehead_cust_id, _sale.saleitem_itemsite_id, 
        _sale.salehead_time::date, 'Retail Sale', _sale.salehead_time::date,
        _sale.salehead_number, _sale.salehead_time, 'R',
        _sale.saleitem_qty, _sale.saleitem_unitprice, _sale.unitcost,
        _sale.salehead_salesrep_id, (_sale.commission * _sale.sale_amount), FALSE,
        _sale.cust_name, _sale.addr_line1,
        _sale.addr_line2, _sale.addr_line3,
        _sale.addr_city, _sale.addr_state, _sale.addr_postalcode,
        _seqRev, _sale.saleitem_taxtype_id);
        
        INSERT INTO cohisttax
        ( taxhist_parent_id, taxhist_taxtype_id, taxhist_tax_id,
          taxhist_basis, taxhist_basis_tax_id, taxhist_sequence,
          taxhist_percent, taxhist_amount, taxhist_tax,
          taxhist_docdate, taxhist_distdate, taxhist_curr_id, taxhist_curr_rate,
          taxhist_journalnumber )
        SELECT _cohistid, taxhist_taxtype_id, taxhist_tax_id,
           taxhist_basis, taxhist_basis_tax_id, taxhist_sequence,
           taxhist_percent, taxhist_amount, taxhist_tax,
           taxhist_docdate, taxhist_distdate, taxhist_curr_id, taxhist_curr_rate,
           taxhist_journalnumber
        FROM xtpos.saleitemtax
        WHERE (taxhist_parent_id=_sale.saleitem_id);
    END IF;
  END LOOP;

  -- Debit register for cash received
  _cshamt := xtpos.reghistsales(_rec.reghist_id,'S');
  
  IF (_test >= 0) THEN
    SELECT insertIntoGLSeries( _seqRev, 'S/O', 'RS', _rec.terminal_number, 
	_rec.reghist_asset_accnt_id, _cshamt * -1, 
	current_date, _noteSales) INTO _test;
  END IF;

  -- Debit check clearing for checks
  _chkamt := xtpos.reghistsales(_rec.reghist_id,'K');
  
  IF (_test >= 0) THEN
    SELECT insertIntoGLSeries( _seqRev, 'S/O', 'RS', _rec.terminal_number, 
	_rec.reghist_chkclr_accnt_id, _chkamt * -1, 
	current_date, _noteSales) INTO _test;
  END IF;

  -- Loop through credit card sales headers and debit CC Account for each trans
  FOR _sale IN
    SELECT
      ccard_type, ccpay_order_number, ccpay_order_number_seq, ccpay_amount
    FROM xtpos.salehead, ccpay, ccard
    WHERE ((salehead_reghist_id=_rec.reghist_id)
     AND (salehead_ccpay_id=ccpay_id)
     AND (ccpay_ccard_id=ccard_id))
  LOOP
    _ccOrderDesc := (_sale.ccard_type || '-' || _sale.ccpay_order_number::TEXT ||
		   '-' || _sale.ccpay_order_number_seq::TEXT);
    SELECT insertIntoGLSeries( _seqRev, 'S/O', 'RS', _ccOrderDesc, 
	   _ccBaglaccntid, _sale.ccpay_amount * -1, current_date, 
	  _noteSales) INTO _test;
  END LOOP;

  --  Create deatil record for register history
  _regdetailid := nextval('regdetail_regdetail_id_seq');
  
  INSERT INTO xtpos.regdetail (
    regdetail_id,
    regdetail_reghist_id,
    regdetail_type,
    regdetail_startbal,
    regdetail_cashslsamt,
    regdetail_bankaccnt_id,
    regdetail_transferamt,
    regdetail_adjustamt,
    regdetail_endbal,
    regdetail_depchks,
    regdetail_username,
    regdetail_notes,
    regdetail_journalnumber )
  VALUES (
    _regdetailid,
    _rec.reghist_id,
    'C',
    _rec.regdetail_endbal,
    _cshamt,
    pBankAccntId,
    _transferAmt,
    _adjustAmt,
    _rec.regdetail_endbal + _cshamt + _transferAmt + _adjustAmt,
    false,
    current_user,
    pNotes,
    _journal );

  -- Deposit checks
  PERFORM xtpos.depositChecks(_regdetailid, _journal);
  
  -- Post Transfers and adjustments
  IF (_transferAmt != 0 AND _test >=0) THEN
    SELECT insertIntoGLSeries( _seqCls, 'S/O', 'MR', _rec.terminal_number, _baglaccntid, 
      _transferAmt, current_date, _noteClose) INTO _test;
  END IF;

  IF (_adjustAmt != 0 AND _test >= 0) THEN
    SELECT insertIntoGLSeries( _seqCls, 'S/O', 'MR', _rec.terminal_number, _rec.reghist_adjust_accnt_id, 
      _adjustAmt, current_date, _noteClose) INTO _test;
  END IF;

  IF (_test >= 0) THEN
    SELECT insertIntoGLSeries( _seqCls, 'S/O', 'MR', _rec.terminal_number, _rec.reghist_asset_accnt_id, 
      (_transferAmt + _adjustAmt) * -1 , current_date, _noteClose ) INTO _test;
  END IF;

  IF (_test >= 0) THEN
    SELECT postGLSeries(_seqRev, _journal, false) INTO _test;
  END IF;

  IF (_test >= 0) THEN
    SELECT postGLSeries(_seqCls, _journal, false) INTO _test;
  END IF;

  IF (_test < 0) THEN
    RAISE EXCEPTION 'An error was encountered posting the g/l transaction.  Error:%',_test::text;
  END IF;

  -- Purge pending sales for this register
  DELETE FROM salehead 
  WHERE ((salehead_terminal_id=pTerminalId)
  AND (salehead_type IN ('S','R'))
  AND (NOT salehead_closed));

  -- Close register session
  UPDATE reghist SET
    reghist_open=false,
    reghist_close_time=now()
  WHERE (reghist_id=_rec.reghist_id);
    
  RETURN _regdetailid;
END;
$$ LANGUAGE 'plpgsql';
