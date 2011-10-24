
SELECT u2.execute($$

-- Sale Item
SELECT dropIfExists('VIEW', 'api_saleitem', 'xtpos');
CREATE VIEW xtpos.api_saleitem
AS
  SELECT
    salehead_number AS sale_number,
    saleitem_linenumber AS line_number,
    item_number,
    item_upccode AS upc,
    item_descrip1 AS description,
    abs(saleitem_qty) AS qty,
    round(saleitem_unitprice,2) AS price,
    round(abs(saleitem_qty) * saleitem_unitprice,2) AS extension,
    abs(round(coalesce(sum(taxhist_tax),0),2)) AS tax
  FROM xtpos.saleitem 
    JOIN xtpos.salehead ON (salehead_id=saleitem_salehead_id)
    JOIN itemsite ON (itemsite_id=saleitem_itemsite_id)
    JOIN item ON (item_id=itemsite_item_id)
    LEFT OUTER JOIN xtpos.saleitemtax ON (saleitem_id=taxhist_parent_id)
  GROUP BY salehead_number,saleitem_linenumber,item_number,
    item_upccode, item_descrip1,saleitem_qty,saleitem_unitprice,
    saleitem_qty
  ORDER BY salehead_number, line_number;

GRANT ALL ON TABLE xtpos.api_saleitem TO xtrole;
COMMENT ON VIEW xtpos.api_saleitem IS 'Sale Item';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO xtpos.api_saleitem DO INSTEAD

  INSERT INTO xtpos.saleitem (
    saleitem_salehead_id,
    saleitem_linenumber,
    saleitem_itemsite_id,
    saleitem_qty,
    saleitem_unitprice )
  VALUES (
    xtpos.getSaleheadId(NEW.sale_number),
    NEW.line_number,
    (SELECT itemsite_id
     FROM xtpos.salehead, itemsite
      JOIN item ON (itemsite_item_id=item_id) 
      JOIN whsinfo ON (itemsite_warehous_id=warehous_id)
     WHERE ((item_number=NEW.item_number)
      AND (salehead_number=NEW.sale_number)
      AND (itemsite_warehous_id=salehead_warehous_id))),
    COALESCE(NEW.qty,1),
    NEW.price );

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO xtpos.api_saleitem DO INSTEAD

  UPDATE xtpos.saleitem SET
    saleitem_linenumber=NEW.line_number,
    saleitem_itemsite_id=(
     SELECT itemsite_id
     FROM xtpos.salehead, itemsite
      JOIN item ON (itemsite_item_id=item_id) 
      JOIN whsinfo ON (itemsite_warehous_id=warehous_id)
     WHERE ((item_number=NEW.item_number)
      AND (salehead_number=NEW.sale_number)
      AND (itemsite_warehous_id=salehead_warehous_id))),
    saleitem_qty=NEW.qty,
    saleitem_unitprice=NEW.price
  WHERE ((saleitem_salehead_id=xtpos.getSaleheadId(OLD.sale_number))
  AND (saleitem_linenumber=OLD.line_number));
             
CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO xtpos.api_saleitem DO INSTEAD

  DELETE FROM xtpos.saleitem 
  WHERE ((saleitem_salehead_id=xtpos.getSaleheadId(OLD.sale_number))
  AND (saleitem_linenumber=OLD.line_number));
  
$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);



-- if version 3.7.5

SELECT u2.execute($$

-- Sale Item
SELECT dropIfExists('VIEW', 'api_saleitem', 'xtpos');
CREATE VIEW xtpos.api_saleitem
AS
  SELECT
    salehead_number AS sale_number,
    saleitem_linenumber AS line_number,
    item_number,
    item_upccode AS upc,
    item_descrip1 AS description,
    abs(saleitem_qty) AS qty,
    round(saleitem_unitprice,2) AS price,
    saleitem_discount AS discount,
    round(abs(saleitem_qty) * saleitem_unitprice,2) AS extension,
    abs(round(coalesce(sum(taxhist_tax),0),2)) AS tax
  FROM xtpos.saleitem 
    JOIN xtpos.salehead ON (salehead_id=saleitem_salehead_id)
    JOIN itemsite ON (itemsite_id=saleitem_itemsite_id)
    JOIN item ON (item_id=itemsite_item_id)
    LEFT OUTER JOIN xtpos.saleitemtax ON (saleitem_id=taxhist_parent_id)
  GROUP BY salehead_number,saleitem_linenumber,item_number,
    item_upccode, item_descrip1,saleitem_qty,saleitem_discount,saleitem_unitprice,
    saleitem_qty
  ORDER BY salehead_number, line_number;

GRANT ALL ON TABLE xtpos.api_saleitem TO xtrole;
COMMENT ON VIEW xtpos.api_saleitem IS 'Sale Item';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO xtpos.api_saleitem DO INSTEAD

  INSERT INTO xtpos.saleitem (
    saleitem_salehead_id,
    saleitem_linenumber,
    saleitem_itemsite_id,
    saleitem_qty,
    saleitem_unitprice,
    saleitem_discount )
  VALUES (
    xtpos.getSaleheadId(NEW.sale_number),
    NEW.line_number,
    (SELECT itemsite_id
     FROM xtpos.salehead, itemsite
      JOIN item ON (itemsite_item_id=item_id) 
      JOIN whsinfo ON (itemsite_warehous_id=warehous_id)
     WHERE ((item_number=NEW.item_number)
      AND (salehead_number=NEW.sale_number)
      AND (itemsite_warehous_id=salehead_warehous_id))),
    COALESCE(NEW.qty,1),
    NEW.price,
    NEW.discount);

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO xtpos.api_saleitem DO INSTEAD

  UPDATE xtpos.saleitem SET
    saleitem_linenumber=NEW.line_number,
    saleitem_itemsite_id=(
     SELECT itemsite_id
     FROM xtpos.salehead, itemsite
      JOIN item ON (itemsite_item_id=item_id) 
      JOIN whsinfo ON (itemsite_warehous_id=warehous_id)
     WHERE ((item_number=NEW.item_number)
      AND (salehead_number=NEW.sale_number)
      AND (itemsite_warehous_id=salehead_warehous_id))),
    saleitem_qty=NEW.qty,
    saleitem_unitprice=NEW.price,
    saleitem_discount=NEW.discount
  WHERE ((saleitem_salehead_id=xtpos.getSaleheadId(OLD.sale_number))
  AND (saleitem_linenumber=OLD.line_number));
             
CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO xtpos.api_saleitem DO INSTEAD

  DELETE FROM xtpos.saleitem 
  WHERE ((saleitem_salehead_id=xtpos.getSaleheadId(OLD.sale_number))
  AND (saleitem_linenumber=OLD.line_number));
  
$$) 
WHERE (u2.knowhow_package_version('xtpos') <= 30705);



