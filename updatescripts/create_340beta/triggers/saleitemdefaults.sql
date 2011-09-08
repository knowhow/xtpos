CREATE OR REPLACE FUNCTION xtpos.saleitemDefaults() RETURNS "trigger" AS $$
DECLARE
  _custid	INTEGER;
  _sale		RECORD;
  _rec		RECORD;
  _taxauthid	INTEGER;
  _taxtypeid	INTEGER;
  
BEGIN
  -- Line number
  NEW.saleitem_linenumber := COALESCE(NEW.saleitem_linenumber,
                                     (SELECT (COALESCE(MAX(saleitem_linenumber), 0) + 1)
                                      FROM xtpos.saleitem
                                      WHERE (saleitem_salehead_id=NEW.saleitem_salehead_id)));
                                 
  -- Make sure sense is correct
  IF (SELECT (salehead_type = 'R')
      FROM xtpos.salehead
      WHERE (salehead_id=NEW.saleitem_salehead_id)) THEN
    NEW.saleitem_qty := abs(NEW.saleitem_qty) * -1;
  ELSE
    NEW.saleitem_qty := abs(NEW.saleitem_qty);
  END IF;
  
  SELECT salehead_cust_id, salehead_taxzone_id, salehead_time,
    getItemTaxType(item_id,salehead_taxzone_id) AS taxtype_id,
    item_id INTO _sale
  FROM itemsite, item, xtpos.salehead
    JOIN xtpos.reghist ON ((reghist_warehous_id=salehead_warehous_id)
			AND (reghist_terminal_id=salehead_terminal_id)
			AND (reghist_open))
  WHERE ((salehead_id=NEW.saleitem_salehead_id)
   AND (itemsite_id=NEW.saleitem_itemsite_id)
   AND (itemsite_item_id=item_id));

  NEW.saleitem_qty := COALESCE(NEW.saleitem_qty,0);

  -- Price
  IF (NEW.saleitem_unitprice IS NULL) THEN
    NEW.saleitem_unitprice	:= round(COALESCE(NEW.saleitem_unitprice,xtpos.itemPrice(_sale.item_id,_sale.salehead_cust_id,abs(NEW.saleitem_qty)),0),4);
  END IF;

  -- Taxes
  IF (_sale.salehead_taxzone_id IS NOT NULL) THEN
    NEW.saleitem_taxtype_id	:= _sale.taxtype_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'saleitemDefaults','xtpos');
CREATE TRIGGER saleitemDefaults BEFORE INSERT OR UPDATE ON xtpos.saleitem FOR EACH ROW EXECUTE PROCEDURE xtpos.saleitemDefaults();
