CREATE OR REPLACE FUNCTION xtpos.getRtlSiteId(text) RETURNS INTEGER AS $$
DECLARE
  pSiteCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pSiteCode IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT rtlsite_id INTO _returnVal
  FROM xtpos.rtlsite, whsinfo
  WHERE ((rtlsite_warehous_id=warehous_id)
  AND (warehous_code=pSiteCode));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION 'Retail Site for % not found.', pSiteCode;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';
