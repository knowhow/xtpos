CREATE TABLE retail.saleitem
(
  saleitem_id serial NOT NULL PRIMARY KEY,
  saleitem_salehead_id integer NOT NULL REFERENCES retail.salehead (salehead_id) ON DELETE CASCADE,
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
GRANT ALL ON retail.saleitem TO openmfg;
GRANT ALL ON retail.saleitem_saleitem_id_seq TO GROUP openmfg;
COMMENT ON TABLE retail.saleitem IS 'Sales Item';
COMMENT ON COLUMN retail.saleitem.saleitem_id IS 'Sale item primary key';
COMMENT ON COLUMN retail.saleitem.saleitem_linenumber IS 'Sale item line number';
COMMENT ON COLUMN retail.saleitem.saleitem_salehead_id IS 'Sale item Sale id';
COMMENT ON COLUMN retail.saleitem.saleitem_itemsite_id IS 'Sale item site id';
COMMENT ON COLUMN retail.saleitem.saleitem_qty IS 'Sale item quantity';
COMMENT ON COLUMN retail.saleitem.saleitem_unitprice IS 'Sale item unit price';
COMMENT ON COLUMN retail.saleitem.saleitem_taxtype_id IS 'Sale item tax type id';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_id IS 'Sale item tax id';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_ratea IS 'Sale item tax rate A';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_rateb IS 'Sale item tax rate B';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_ratec IS 'Sale item tax rate C';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_pcta IS 'Sale item tax percent A';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_pctb IS 'Sale item tax percent B';
COMMENT ON COLUMN retail.saleitem.saleitem_tax_pctc IS 'Sale item tax percent C';
COMMENT ON COLUMN retail.saleitem.saleitem_taxtype_id IS 'Sale item tax id';
COMMENT ON COLUMN retail.saleitem.saleitem_invhist_id IS 'Sale item inventory history id';
