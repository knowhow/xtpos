--
-- This file is part of the knowhow ERP, a free and open source
-- Enterprise Resource Planning software suite,
-- Copyright (c) 2010-2011 by bring.out doo Sarajevo.
-- It is licensed to you under the Common Public Attribution License
-- version 1.0, the full text of which (including knowhow-specific Exhibits)
-- is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
-- root directory of this source code archive.
-- By using this software, you agree to be bound by its terms.
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
WHERE (u2.knowhow_package_version('xtpos') < 30703);

