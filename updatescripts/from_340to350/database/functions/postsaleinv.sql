CREATE OR REPLACE FUNCTION xtpos.postSaleInv(integer) RETURNS bool AS $$
DECLARE
  pSaleheadId 		ALIAS FOR $1;
  _invhistid		INTEGER;
  _itemlocseries	INTEGER := nextval('itemloc_series_seq');
  _sale			RECORD;
  
BEGIN  
  -- Post inventory
  FOR _sale IN
    SELECT salehead_number, salehead_cust_id, 
      saleitem_id, saleitem_qty, 
      itemsite_id, itemsite_controlmethod, 
      costcat_asset_accnt_id,
      item_number, item_type
    FROM xtpos.salehead
      JOIN xtpos.saleitem ON (salehead_id=saleitem_salehead_id)
      JOIN itemsite ON (saleitem_itemsite_id=itemsite_id)
      JOIN item ON (itemsite_item_id=item_id)
      JOIN costcat ON (itemsite_costcat_id=costcat_id)
    WHERE (saleitem_salehead_id=pSaleheadId)
  LOOP
    IF (_sale.itemsite_controlmethod IN ('L','S')) THEN
      RAISE EXCEPTION 'Lot/Serial controlled items are not supported by the retail module at this time';
    ELSIF (_sale.item_type = 'J') THEN
      RAISE EXCEPTION 'Job items are not supported by the retail module.';
    ELSIF (_sale.itemsite_controlmethod = 'R') THEN

      SELECT postInvTrans( _sale.itemsite_id, 'RS', _sale.saleitem_qty * -1,
  			   'S/O', 'RS',
			   _sale.salehead_number, _sale.salehead_number, 
			   'Item Sale: ' || _sale.item_number,
			   _sale.costcat_asset_accnt_id,
			   resolveCOSAccount(_sale.itemsite_id, _sale.salehead_cust_id), 
			   _itemlocSeries, now() ) INTO _invhistid;

      IF (_invhistid < 0) THEN
        RAISE EXCEPTION 'An error occurred processing an inventory transaction.  Error:%', _invhistid;
      ELSE
        PERFORM postItemlocseries(_itemlocSeries);
        
        UPDATE xtpos.saleitem SET
          saleitem_invhist_id=_invhistid
        WHERE (saleitem_id=_sale.saleitem_id);
      END IF;
    END IF;
  END LOOP;
  
  RETURN true;
END;
$$ LANGUAGE 'plpgsql';
