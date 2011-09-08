CREATE OR REPLACE FUNCTION xtpos.rtlsiteStatusCheck() RETURNS "trigger" AS $$
DECLARE
  _t   		RECORD;
  _endbal	NUMERIC;
BEGIN
  -- Make sure terminal isn't open
  IF (SELECT (count(reghist_id) > 1)
      FROM xtpos.reghist
      WHERE ((reghist_warehous_id=OLD.rtlsite_warehous_id)
       AND (reghist_open))) THEN
    RAISE EXCEPTION 'Retail Site may not be deleted when one or more registers are open';
  END IF;

  -- Make sure there's no money in one of the registers
  FOR _t IN
    SELECT rtlsiteterm_terminal_id
    FROM xtpos.rtlsiteterm
    WHERE (rtlsiteterm_rtlsite_id=OLD.rtlsite_id)
  LOOP
    SELECT regdetail_endbal INTO _endbal
    FROM xtpos.reghist
      JOIN xtpos.regdetail ON (reghist_id=regdetail_reghist_id)
    WHERE ((reghist_warehous_id=OLD.rtlsite_warehous_id)
    AND (reghist_terminal_id=_t.rtlsiteterm_terminal_id))
    ORDER BY regdetail_time DESC
    LIMIT 1;

    IF (FOUND) THEN
      IF (_endbal > 0) THEN
        RAISE EXCEPTION 'Retail Site may not be deleted when one or more registers has an outstanding balance';
      END IF;
    END IF;
  END LOOP;

  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'rtlsiteStatusCheck','xtpos');
CREATE TRIGGER rtlsiteStatusCheck BEFORE DELETE ON xtpos.rtlsite FOR EACH ROW EXECUTE PROCEDURE xtpos.rtlsiteStatusCheck();
