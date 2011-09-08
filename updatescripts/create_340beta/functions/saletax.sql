CREATE OR REPLACE FUNCTION xtpos.saletax(integer) RETURNS NUMERIC AS $$
DECLARE
  pSaleheadId 	ALIAS FOR $1;
  _totalSales  	NUMERIC;
  _r		RECORD;
  _returnVal	NUMERIC := 0;

BEGIN

  FOR _r IN SELECT
              coalesce(round(sum(taxhist_tax),2),0) AS tax
            FROM xtpos.saleitemtax
              JOIN xtpos.saleitem ON (saleitem_id=taxhist_parent_id)
              JOIN tax ON (taxhist_tax_id=tax_id)
            WHERE (saleitem_salehead_id=pSaleheadId)
	    GROUP BY tax_id, tax_sales_accnt_id 
  LOOP

    _returnVal := _returnVal + _r.tax;
  END LOOP;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';