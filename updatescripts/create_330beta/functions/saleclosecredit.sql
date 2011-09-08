CREATE OR REPLACE FUNCTION xtpos.saleCloseCredit(integer, integer, numeric) RETURNS bool AS $$
DECLARE
  pSaleheadId 	ALIAS FOR $1;
  pCcpayId	ALIAS FOR $2;
  pTendered    	ALIAS FOR $3;
  _rec		RECORD;
  _amount	NUMERIC;
  
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
    ELSIF (_rec.salehead_type = 'Q') THEN
      RAISE EXCEPTION 'Can not record payment against a Quote.';
    END IF;
    
    -- Post inventory
    PERFORM postSaleInv(pSaleheadId);

    IF (_rec.salehead_type = 'R') THEN
      _amount := pTendered * -1;
    ELSE
      _amount := pTendered;
    END IF;
    
    -- Close the sale
    UPDATE xtpos.salehead SET
      salehead_closed=true,
      salehead_time=now(),
      salehead_cashamt=_amount,
      salehead_ccpay_id=pCcpayId,
      salehead_reghist_id=_rec.reghist_id
    WHERE (salehead_id=pSaleheadId);
  ELSE
    RAISE EXCEPTION 'Register is not open';
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE 'plpgsql';
