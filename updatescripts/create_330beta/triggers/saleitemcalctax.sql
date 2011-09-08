CREATE OR REPLACE FUNCTION xtpos.saleitemCalcTax() RETURNS "trigger" AS $$
BEGIN
  PERFORM calculateTaxHist( 'xtpos.saleitemtax',
                            NEW.saleitem_id,
                            COALESCE(salehead_taxzone_id, -1),
                            NEW.saleitem_taxtype_id,
                            COALESCE(salehead_time::date, CURRENT_DATE),
                            basecurrid(),
                            NEW.saleitem_unitprice * NEW.saleitem_qty)
  FROM xtpos.salehead 
  WHERE (salehead_id=NEW.saleitem_salehead_id);

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'saleitemCalcTax','xtpos');
CREATE TRIGGER saleitemCalcTax AFTER INSERT OR UPDATE ON xtpos.saleitem FOR EACH ROW EXECUTE PROCEDURE xtpos.saleitemCalcTax();