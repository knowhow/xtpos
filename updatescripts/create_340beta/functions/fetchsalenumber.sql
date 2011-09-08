CREATE OR REPLACE FUNCTION xtpos.fetchSaleNumber() RETURNS TEXT AS $$
DECLARE
  _saleNumber TEXT;
  _test INTEGER;

BEGIN

  LOOP

    _saleNumber := nextval('sale_number_seq');

    SELECT salehead_id INTO _test
    FROM xtpos.salehead
    WHERE (salehead_number=_saleNumber);

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _saleNumber;

END;
$$ LANGUAGE 'plpgsql';
