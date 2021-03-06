CREATE OR REPLACE FUNCTION xtpos.saleheadPrivCheck() RETURNS "trigger" AS $$
BEGIN
  -- Privilege Checks
  IF (NOT checkPrivilege('MaintainRetailSales')) THEN
    RAISE EXCEPTION 'You do not have privileges to edit cash register sales.';
  END IF;

  IF (TG_OP = 'DELETE') THEN
    DELETE FROM xtpos.saleitem WHERE saleitem_salehead_id = OLD.salehead_id; -- Issue #9608
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'saleheadPrivCheck', 'xtpos');
CREATE TRIGGER saleheadPrivCheck BEFORE INSERT OR UPDATE OR DELETE ON xtpos.salehead FOR EACH ROW EXECUTE PROCEDURE xtpos.saleheadPrivCheck();
