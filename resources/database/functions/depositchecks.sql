CREATE OR REPLACE FUNCTION xtpos.depositChecks(integer, integer) RETURNS NUMERIC AS $$
DECLARE
  pRegdetailId 		ALIAS FOR $1;
  pJournalNumber	ALIAS FOR $2;
  _rec			RECORD;
  _amt			NUMERIC := 0;
  _noteDeposit		TEXT;
  _seq			INTEGER;
  _test			INTEGER := 0;
  
BEGIN    

  _seq		:= fetchGLSequence();
    
  -- Loop through undeposited checks on this register session
  FOR _rec IN 
  SELECT
    salehead_id, salehead_number, salehead_cashamt, salehead_checkamt,
    salehead_checknumber,salehead_cust_id, regdetail_bankaccnt_id, 
    reghist_chkclr_accnt_id, terminal_number, bankaccnt_accnt_id
  FROM  xtpos.regdetail
    JOIN xtpos.reghist ON (reghist_id=regdetail_reghist_id)
    JOIN xtpos.salehead ON ((salehead_reghist_id=reghist_id)
			  AND (salehead_checkamt > 0)
                         AND (salehead_regdetail_id IS NULL))
    JOIN terminal ON (reghist_terminal_id=terminal_id)
    JOIN bankaccnt ON (bankaccnt_id=regdetail_bankaccnt_id)
  WHERE (regdetail_id=pRegdetailId)
  LOOP
    _noteDeposit 	:= 'Check deposit for terminal ' || _rec.terminal_number;
    
--  Record the check application
    INSERT INTO arapply
    ( arapply_cust_id,
      arapply_source_aropen_id, arapply_source_doctype, arapply_source_docnumber,
      arapply_target_aropen_id, arapply_target_doctype, arapply_target_docnumber,
      arapply_fundstype, arapply_refnumber,
      arapply_applied, arapply_closed,
      arapply_postdate, arapply_distdate, arapply_journalnumber, arapply_username,
      arapply_curr_id )
    VALUES
    ( _rec.salehead_cust_id,
      -1, 'K', '', 
      -1, 'Point of Sale', _rec.salehead_number,
      'C', _rec.salehead_checknumber,
      _rec.salehead_checkamt, TRUE,
      CURRENT_DATE, current_date, pJournalNumber, CURRENT_USER, basecurrid() );

    -- Debit bank account
    SELECT insertIntoGLSeries( _seq, 'S/O', 'RS',
	'C-'|| _rec.salehead_checknumber, _rec.bankaccnt_accnt_id,
        _rec.salehead_checkamt * -1, current_date, _noteDeposit) INTO _test;

    IF (_test < 0) THEN
      RAISE EXCEPTION 'An error was encountered posting the g/l transaction.  Error:%',_test::text;
    END IF;

    _amt := _amt + _rec.salehead_checkamt;
    
    --  Update the sale that this check is being cleared
    
    UPDATE salehead SET
      salehead_regdetail_id=pRegdetailId
    WHERE (salehead_id=_rec.salehead_id);

  END LOOP;
  
  -- Credit check clearing
  IF (_amt > 0) THEN
    SELECT insertIntoGLSeries( _seq, 'S/O', 'RS', _rec.terminal_number, 
	_rec.reghist_chkclr_accnt_id, _amt, current_date, _noteDeposit) INTO _test;

    IF (_test < 0) THEN
      RAISE EXCEPTION 'An error was encountered posting the g/l transaction.  Error:%',_test::text;
    END IF;
  END IF;

  IF (_test >= 0) THEN
    SELECT postGLSeries(_seq, pJournalNumber, false) INTO _test;
  END IF;

  RETURN _amt;
          
END;
$$ LANGUAGE 'plpgsql';
