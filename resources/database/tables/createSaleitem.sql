--
-- The contents of this file are subject to the Common Public Attribution License Version 1.0 (the "License"); 
-- you may not use this file except in compliance with the License. 
-- You may obtain a copy of the License at http://www.xTuple.com/CPAL.  
-- The License is based on the Mozilla Public License Version 1.1 but Sections 14 and 15 
-- have been added to cover use of software over a computer network and provide for limited attribution 
-- for the Original Developer. In addition, Exhibit A has been modified to be consistent with Exhibit B.
--
-- Software distributed under the License is distributed on an "AS IS" basis, 
-- WITHOUT WARRANTY OF ANY KIND, either express or implied. 
-- See the License for the specific language governing rights and limitations under the License. 
--
-- The Original Code is xTuple ERP: PostBooks Edition
--
-- The Initial Developer of the Original Code is OpenMFG, LLC, d/b/a xTuple. 
-- All portions of the code written by xTuple are Copyright (c) 1999-2011 
-- OpenMFG, LLC, d/b/a xTuple. All Rights Reserved. 
--
-- Contributor(s):
-- - hernad - Ernad Husremovic, hernad@bring.out.ba
--
-- ----------------------------------------------------------------------------
-- 
-- Modified by bring.out doo Sarajevo as part of knowhow ERP project 2010-2011.  
--

SELECT u2.execute($$

CREATE TABLE xtpos.saleitem
(
  saleitem_id serial NOT NULL PRIMARY KEY,
  saleitem_salehead_id integer NOT NULL REFERENCES xtpos.salehead (salehead_id),
  saleitem_linenumber integer NOT NULL,
  saleitem_itemsite_id integer NOT NULL REFERENCES itemsite (itemsite_id),
  saleitem_qty numeric NOT NULL,
  saleitem_unitprice numeric NOT NULL DEFAULT 0,
  saleitem_taxtype_id INTEGER REFERENCES taxtype (taxtype_id),
  saleitem_tax_id INTEGER REFERENCES tax (tax_id),
  saleitem_tax_pcta numeric DEFAULT 0,
  saleitem_tax_pctb numeric DEFAULT 0,
  saleitem_tax_pctc numeric DEFAULT 0,
  saleitem_tax_ratea numeric DEFAULT 0, 
  saleitem_tax_rateb numeric DEFAULT 0, 
  saleitem_tax_ratec numeric DEFAULT 0, 
  saleitem_invhist_id INTEGER REFERENCES invhist (invhist_id),
  CONSTRAINT saleitem_saleitem_salehead_id_key UNIQUE (saleitem_salehead_id, saleitem_linenumber)
);
GRANT ALL ON xtpos.saleitem TO xtrole;
GRANT ALL ON xtpos.saleitem_saleitem_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.saleitem IS 'Line item for a cash register sale';
COMMENT ON COLUMN xtpos.saleitem.saleitem_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.saleitem.saleitem_linenumber IS 'Sale item line number';
COMMENT ON COLUMN xtpos.saleitem.saleitem_salehead_id IS 'Internal id of the parent sale record';
COMMENT ON COLUMN xtpos.saleitem.saleitem_itemsite_id IS 'Internal id of the (item, site) pair - which item was sold and which site the inventory came from';
COMMENT ON COLUMN xtpos.saleitem.saleitem_qty IS 'Sale item quantity';
COMMENT ON COLUMN xtpos.saleitem.saleitem_unitprice IS 'Sale item unit price';
COMMENT ON COLUMN xtpos.saleitem.saleitem_taxtype_id IS 'Sale item tax type id';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_id IS 'Sale item tax id';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_ratea IS 'Amount of tax A that was charged for this line item';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_rateb IS 'Amount of tax B that was charged for this line item';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_ratec IS 'Amount of tax C that was charged for this line item';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_pcta IS 'The percentage of the line item price required by tax A';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_pctb IS 'The percentage of the line item price required by tax B';
COMMENT ON COLUMN xtpos.saleitem.saleitem_tax_pctc IS 'The percentage of the line item price required by tax C';
COMMENT ON COLUMN xtpos.saleitem.saleitem_taxtype_id IS 'The type of tax that was charged for this line item (food tax vs. service tax vs. ...)';
COMMENT ON COLUMN xtpos.saleitem.saleitem_invhist_id IS 'Internal id of the inventory history record recording the sale of this line itemi';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30702);


-- if version 3.7.5
SELECT u2.execute($$

-- add discount to saleitem table
ALTER TABLE xtpos.saleitem
            ADD saleitem_discount numeric DEFAULT 0;

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30705);


SELECT u2.execute($$

-- add unitprice_discounted to saleitem table
ALTER TABLE xtpos.saleitem
            ADD saleitem_unitprice_discounted numeric DEFAULT 0;

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30706);


