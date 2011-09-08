CREATE OR REPLACE FUNCTION xtpos.saleCloseCheck(integer, text, numeric, numeric) RETURNS bool AS $$
DECLARE
  pSaleheadId 	ALIAS FOR $1;
  pCheckNumber	ALIAS FOR $2;
  pCheckAmt	ALIAS FOR $3;
  pTendered	ALIAS FOR $4;
  _rec		RECORD;
  
BEGIN    
  -- Find the open register history record to bind sale to
  SELECT reghist_id, salehead_closed, salehead_type INTO _rec
  FROM xtpos.salehead
   JOIN xtpos.reghist 	ON ((reghist_terminal_id=salehead_terminal_id)
			AND (reghist_open))
  WHERE (salehead_id=pSaleheadId);

  IF (FOUND) THEN
    IF (_rec.salehead_closed) THEN
      RAISE EXCEPTION 'Sale is already closed.';
    ELSIF (_rec.salehead_type IN ('Q','R')) THEN
      RAISE EXCEPTION 'Checks may not be processed against Quotes or Returns.';
    END IF;
    
     -- Post inventory
     PERFORM xtpos.postSaleInv(pSaleheadId);
  
    -- Close the sale
    UPDATE xtpos.salehead SET
      salehead_closed=true,
      salehead_time=now(),
      salehead_checknumber=pCheckNumber,
      salehead_checkamt=pCheckAmt,
      salehead_cashamt=pTendered,
      salehead_reghist_id=_rec.reghist_id
    WHERE (salehead_id=pSaleheadId);
  ELSE
    RAISE EXCEPTION 'Register is not open';
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE 'plpgsql';
