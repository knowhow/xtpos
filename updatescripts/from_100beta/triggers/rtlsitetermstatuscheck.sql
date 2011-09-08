CREATE OR REPLACE FUNCTION xtpos.rtlsitetermStatusCheck() RETURNS "trigger" AS $$
DECLARE
  _endbal	NUMERIC;
BEGIN
  -- Make sure terminal isn't open
  IF (SELECT (count(reghist_id) > 1)
      FROM xtpos.reghist
      WHERE ((reghist_terminal_id=OLD.rtlsiteterm_terminal_id)
       AND (reghist_open))) THEN
    RAISE EXCEPTION 'Terminal % may not be disassociated from retail site while it is open', OLD.terminal_number;
  END IF;

  -- Make sure there's no money in the register
  SELECT regdetail_endbal INTO _endbal
  FROM xtpos.regdetail
    JOIN xtpos.reghist ON (reghist_id=regdetail_reghist_id)
  WHERE (reghist_terminal_id=OLD.rtlsiteterm_terminal_id)
  ORDER BY regdetail_time DESC
  LIMIT 1;

  IF (FOUND) THEN
    IF (_endbal > 0) THEN
      RAISE EXCEPTION 'Terminal may not be deleted when it has an outstanding balance';
    END IF;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'rtlsitetermStatusCheck','xtpos');
CREATE TRIGGER rtlsitetermStatusCheck BEFORE DELETE ON xtpos.rtlsiteterm FOR EACH ROW EXECUTE PROCEDURE xtpos.rtlsitetermStatusCheck();
