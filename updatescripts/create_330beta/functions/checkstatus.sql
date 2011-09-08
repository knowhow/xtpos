CREATE OR REPLACE FUNCTION xtpos.checkStatus(integer) RETURNS BOOL AS $$
DECLARE
  pSaleheadId ALIAS FOR $1;
  _rec		RECORD;
  _expires	DATE;
  _closed	BOOLEAN;
BEGIN
  SELECT salehead_type, salehead_time, salehead_closed, salehead_warehous_id INTO _rec
  FROM xtpos.salehead
  WHERE (salehead_id=pSaleheadId);

  IF (FOUND) THEN
    IF ((_rec.salehead_type = 'Q') AND (NOT _rec.salehead_closed)) THEN
      SELECT (current_date - rtlsite_quotedays) INTO _expires
      FROM xtpos.rtlsite
      WHERE (rtlsite_warehous_id=_rec.salehead_warehous_id);

      IF (FOUND) THEN
        _closed := (_rec.salehead_time < _expires);
      ELSE
        _closed := true;
      END IF;

      IF (_closed) THEN
        UPDATE xtpos.salehead SET
          salehead_closed = true
        WHERE (salehead_id=pSaleheadId);
      END IF;
    ELSE
      _closed := _rec.salehead_closed;
    END IF;
  ELSE
    RAISE EXCEPTION 'Sale not found.';
  END IF;

  RETURN _closed;
END;
$$ LANGUAGE 'plpgsql';
