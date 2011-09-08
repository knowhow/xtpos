CREATE OR REPLACE FUNCTION xtpos.saleitemStatusCheck() RETURNS "trigger" AS $$
DECLARE  
  _saleheadid	INTEGER;
  
BEGIN
  IF (TG_OP = 'INSERT') THEN
    _saleheadid := NEW.saleitem_salehead_id;
  ELSE
    _saleheadid := OLD.saleitem_salehead_id;
  END IF;
  
  -- Make sure sale is open
  IF (SELECT (salehead_closed)
      FROM xtpos.salehead
      WHERE (salehead_id=_saleheadid)) THEN
    RAISE NOTICE 'Closed sale may not be edited or deleted';
    RETURN OLD;
  END IF;

  IF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'saleitemStatusCheck','xtpos');
CREATE TRIGGER saleitemStatusCheck BEFORE INSERT OR UPDATE OR DELETE ON xtpos.saleitem FOR EACH ROW EXECUTE PROCEDURE xtpos.saleitemStatusCheck();
