CREATE OR REPLACE FUNCTION xtpos.cashRegAdjust(integer, integer, numeric, bpchar, bool, numeric, bpchar, text) RETURNS INTEGER AS $$
DECLARE
  pTerminalId	ALIAS FOR $1;
  pBankAccntId	ALIAS FOR $2;
  _transferAmt	NUMERIC := COALESCE($3,0);
  pTransferDir	ALIAS FOR $4;
  pDepChecks	ALIAS FOR $5;
  _adjustAmt	NUMERIC := COALESCE($6,0);
  pAdjustDir	ALIAS FOR $7;
  pNotes	ALIAS FOR $8;
  _baglaccntid	INTEGER;
  _journal	INTEGER;
  _prevbal	NUMERIC;
  _rec	 	RECORD;
  _regdetailid	INTEGER;
  _reghistid	INTEGER;
  _sequence  	INTEGER;
  _test 	INTEGER := 0;
  
BEGIN  
  -- If no amounts, ignore
  IF (_transferAmt = 0 AND _adjustAmt = 0) THEN
    RAISE NOTICE 'No amount to process';
    
    RETURN 0;
    
  -- Validate
  ELSIF (_transferAmt < 0 OR _adjustAmt < 0) THEN
    RAISE EXCEPTION 'Negative amounts may not be entered';
  ELSIF (pTransferDir NOT IN ('I','O') OR pAdjustDir NOT IN ('I','O')) THEN
    RAISE EXCEPTION 'Invalid amount direction.  Valid directions are "I" (In) and "O" (Out)'; 
  END IF;
  
  -- Fetch history data
  SELECT reghist_id, reghist_asset_accnt_id, reghist_adjust_accnt_id,
    regdetail_endbal, terminal_number INTO _rec
  FROM xtpos.reghist
    JOIN xtpos.regdetail ON (reghist_id=regdetail_reghist_id)
    JOIN xtpos.terminal ON (reghist_terminal_id=terminal_id)
  WHERE ((terminal_id=pTerminalId)
   AND (reghist_open))
  ORDER BY regdetail_time DESC
  LIMIT 1;

  IF (FOUND) THEN
    _reghistid 	:= _rec.reghist_id;
    _prevbal	:= _rec.regdetail_endbal;
  ELSE
    --  Register closed, need to make a history record to record this against
    SELECT rtlsite_asset_accnt_id AS reghist_asset_accnt_id, 
      rtlsite_adjust_accnt_id AS reghist_adjust_accnt_id,
      rtlsite_chkclr_accnt_id AS reghist_chkclr_accnt_id,
      warehous_id, terminal_number INTO _rec
    FROM xtpos.rtlsiteterm
      JOIN xtpos.rtlsite ON (rtlsiteterm_rtlsite_id=rtlsite_id)
      JOIN xtpos.terminal ON (rtlsiteterm_terminal_id=terminal_id)
      JOIN whsinfo ON (rtlsite_warehous_id=warehous_id)
    WHERE (rtlsiteterm_terminal_id=pTerminalId);
  
    IF (FOUND) THEN
      _reghistid := nextval('reghist_reghist_id_seq');
    
      INSERT INTO xtpos.reghist (
        reghist_id,
        reghist_warehous_id,
        reghist_terminal_id,
        reghist_asset_accnt_id,
        reghist_adjust_accnt_id,
        reghist_chkclr_accnt_id,
        reghist_open,
        reghist_open_time,
        reghist_close_time )
      VALUES (
        _reghistid,
        _rec.warehous_id,
        pTerminalId,
        _rec.reghist_asset_accnt_id,
        _rec.reghist_adjust_accnt_id,
        _rec.reghist_chkclr_accnt_id,
        false,
        now(),
        now() );

      -- Fetch previous balance
      SELECT regdetail_endbal INTO _prevbal
      FROM xtpos.reghist
        JOIN xtpos.regdetail ON (reghist_id=regdetail_reghist_id)
      WHERE (reghist_terminal_id=pTerminalId)
      ORDER BY regdetail_time DESC
      LIMIT 1;
    ELSE
      RAISE EXCEPTION 'Retail Site not found';
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
  ELSIF (pBankAcctId IS NULL AND COALESCE(pTransferAmt,0) > 0) THEN
    RAISE EXCEPTION 'Bank account must be provided to process transfer';
  END IF;

  IF (pAdjustDir = 'O') THEN
    _adjustAmt := _adjustAmt * -1;
  END IF;

  IF (pTransferDir = 'O') THEN
    _transferAmt := _transferAmt * -1;
  END IF;

  _journal	:= fetchJournalNumber('S/O');
  _sequence 	:= fetchGLSequence();

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
    _reghistid,
    'A',
    _prevbal,
    0,
    pBankAccntId,
    _transferAmt,
    _adjustAmt,
    _prevbal + _transferAmt + _adjustAmt,
    false,
    current_user,
    pNotes,
    _journal );

  -- Record G/L transactions where applicable

  IF (pDepChecks) THEN
    PERFORM xtpos.depositChecks(_regdetailid, _journal);
  END IF;

  IF (_transferAmt != 0 AND _test >= 0) THEN
    SELECT insertIntoGLSeries( _sequence, 'S/O', 'MR', _rec.terminal_number, _baglaccntid, 
      _transferAmt, current_date, 'Cash register bank transfer') INTO _test;
  END IF;

  IF (_adjustAmt != 0 AND _test >= 0)  THEN
    SELECT insertIntoGLSeries( _sequence, 'S/O', 'MR', _rec.terminal_number, _rec.reghist_adjust_accnt_id, 
      _adjustAmt, current_date, 'Cash register adjustment') INTO _test;
  END IF;

  IF (_test >= 0) THEN
    SELECT insertIntoGLSeries( _sequence, 'S/O', 'MR', _rec.terminal_number, _rec.reghist_asset_accnt_id, 
      (_transferAmt + _adjustAmt) * -1 , current_date, 'Cash register adjustment transaction') INTO _test;
  END IF;

  IF (_test >= 0) THEN
    SELECT postGLSeries(_sequence, _journal, false) INTO _test;
  END IF;

  IF (_test < 0) THEN
    RAISE EXCEPTION 'An error was encountered posting the g/l transaction.  Error:%',_test::text;
  END IF;
    
  RETURN _regdetailid;
END;
$$ LANGUAGE 'plpgsql';
