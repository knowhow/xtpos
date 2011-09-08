CREATE OR REPLACE FUNCTION xtpos.cashRegOpen(integer, integer, numeric, bpchar, numeric, bpchar, text) RETURNS INTEGER AS $$
DECLARE
  pTerminalId	ALIAS FOR $1;
  pBankAccntId	ALIAS FOR $2;
  _transferAmt	NUMERIC := COALESCE($3,0);
  pTransferDir	ALIAS FOR $4;
  _adjustAmt	NUMERIC := COALESCE($5,0);
  pAdjustDir	ALIAS FOR $6;
  pNotes	ALIAS FOR $7;
  _baglaccntid	INTEGER;
  _def		RECORD;
  _journal	INTEGER;
  _noteOpen	TEXT;
  _prevbal      NUMERIC;
  _regdetailid	INTEGER;
  _reghistid 	INTEGER;
  _sequence  	INTEGER;
  _test		INTEGER := 0;
  
BEGIN  
  -- Validate
  IF (_transferAmt < 0 OR _adjustAmt < 0) THEN
    RAISE EXCEPTION 'Negative amounts may not be entered';
  ELSIF (pTransferDir NOT IN ('I','O') OR pAdjustDir NOT IN ('I','O')) THEN
    RAISE EXCEPTION 'Invalid amount direction.  Valid directions are "I" (In) and "O" (Out)'; 
    
  -- Check to make sure register is not already open
  ELSIF (SELECT (count(reghist_id) > 0) 
      FROM xtpos.reghist
      WHERE ((reghist_terminal_id=pTerminalId)
      AND (reghist_open))) THEN
    RAISE EXCEPTION 'Terminal register is already open';
    
  -- Fetch Bank Account G/L Account Id
  ELSIF (pBankAccntId IS NOT NULL) THEN
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

  IF (pAdjustDir = 'O') THEN
    _adjustAmt := _adjustAmt * -1;
  END IF;

  IF (pTransferDir = 'O') THEN
    _transferAmt := _transferAmt * -1;
  END IF;
  
  -- Fetch retail site record and corresponding data 
  SELECT rtlsite_asset_accnt_id, rtlsite_adjust_accnt_id,
         rtlsite_chkclr_accnt_id,
         warehous_id,
         terminal_number INTO _def
  FROM xtpos.rtlsite
    JOIN whsinfo ON (rtlsite_warehous_id=warehous_id)
    JOIN xtpos.rtlsiteterm ON (rtlsite_id=rtlsiteterm_rtlsite_id)
    JOIN xtpos.terminal ON (terminal_id=rtlsiteterm_terminal_id)
  WHERE (terminal_id=pTerminalId);
  
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
      reghist_open_time )
    VALUES (
      _reghistid,
      _def.warehous_id,
      pTerminalId,
      _def.rtlsite_asset_accnt_id,
      _def.rtlsite_adjust_accnt_id,
      _def.rtlsite_chkclr_accnt_id,
      true,
      now() );
  ELSE
    RAISE EXCEPTION 'Retail Site Terminal not found';
  END IF;

  -- Fetch previous balance
  SELECT regdetail_endbal INTO _prevbal
  FROM xtpos.reghist
    JOIN xtpos.regdetail ON (reghist_id=regdetail_reghist_id)
  WHERE (reghist_terminal_id=pTerminalId)
  ORDER BY regdetail_time DESC
  LIMIT 1;

  -- Record G/L transactions if applicable
  IF (_transferAmt != 0 OR _adjustAmt != 0) THEN
    _noteOpen	:= 'Open posting for terminal ' || _def.terminal_number;
    _sequence 	:= fetchGLSequence();
    _journal	:= fetchJournalNumber('S/O');

    IF (_transferAmt != 0 AND _test >=0) THEN
      SELECT insertIntoGLSeries( _sequence, 'S/O', 'MR', _def.terminal_number, _baglaccntid, 
        _transferAmt, current_date, _noteOpen) INTO _test;
    END IF;

    IF (_adjustAmt != 0 AND _test >=0) THEN
      SELECT insertIntoGLSeries( _sequence, 'S/O', 'MR', _def.terminal_number, _def.rtlsite_adjust_accnt_id, 
        _adjustAmt, current_date, _noteOpen) INTO _test;     
    END IF;

    IF (_test >= 0) THEN
      SELECT insertIntoGLSeries( _sequence, 'S/O', 'MR', _def.terminal_number, _def.rtlsite_asset_accnt_id, 
        (_transferAmt + _adjustAmt) * -1 , current_date, _noteOpen) INTO _test;
    END IF;

    IF (_test >= 0) THEN
      SELECT postGLSeries(_sequence, _journal, false) INTO _test;
    END IF;
  END IF;

  IF (_test < 0) THEN
    RAISE EXCEPTION 'An error was encountered posting the g/l transaction.  Error:%',_test::text;
  END IF;

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
    'O',
    COALESCE(_prevbal,0),
    0,
    pBankAccntId,
    _transferAmt,
    _adjustAmt,
    COALESCE(_prevbal,0) + _transferAmt + _adjustAmt,
    false,
    current_user,
    pNotes,
    _journal );
    
  RETURN _regdetailid;
END;
$$ LANGUAGE 'plpgsql';
