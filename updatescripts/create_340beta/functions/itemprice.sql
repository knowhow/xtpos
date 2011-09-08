CREATE OR REPLACE FUNCTION xtpos.itemPrice(INTEGER, INTEGER, NUMERIC) RETURNS NUMERIC AS $$
DECLARE
  pItemid ALIAS FOR $1;
  pCustid ALIAS FOR $2;
  pQty ALIAS FOR $3;

BEGIN
  RETURN itemPrice(pItemid, pCustid, -1, pQty, baseCurrId(), CURRENT_DATE);
END;
$$ LANGUAGE 'plpgsql';
