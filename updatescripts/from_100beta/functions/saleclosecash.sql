CREATE OR REPLACE FUNCTION xtpos.saleCloseCash(integer, numeric) RETURNS bool AS $$
DECLARE
  pSaleheadId 	ALIAS FOR $1;
  pTendered	ALIAS FOR $2;
  _rec		RECORD;
  _amount	NUMERIC;
  
BEGIN  
  -- Sum sale and fetch register history record to bind sale to
  SELECT sum(round((saleitem_qty * saleitem_unitprice) + 
    saleitem_tax_ratea + saleitem_tax_rateb + saleitem_tax_ratec, 2)) AS saleamt,
    reghist_id, salehead_closed, salehead_type INTO _rec
  FROM xtpos.salehead
   JOIN xtpos.saleitem ON (salehead_id=saleitem_salehead_id)
   JOIN xtpos.reghist 	ON ((reghist_terminal_id=salehead_terminal_id)
			AND (reghist_open))
  WHERE (salehead_id=pSaleheadId)
  GROUP BY reghist_id, salehead_closed, salehead_type;

  IF (FOUND) THEN
    -- Check status
    IF (_rec.salehead_closed) THEN
      RAISE EXCEPTION 'The sale is already closed.';
    -- Check amount
    ELSIF (pTendered < _rec.saleamt) THEN
      RAISE EXCEPTION 'The tendered amout % is less than the sale amount of %.', pTendered::text, _rec.saleamt::text;
    ELSIF (_rec.salehead_type = 'Q') THEN
      RAISE EXCEPTION 'Can not record payment against a Quote.';
    END IF;

    -- Post inventory
    PERFORM xtpos.postSaleInv(pSaleheadId);

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
      salehead_reghist_id=_rec.reghist_id
    WHERE (salehead_id=pSaleheadId);
  ELSE
    RAISE EXCEPTION 'Register is not open';
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE 'plpgsql';
