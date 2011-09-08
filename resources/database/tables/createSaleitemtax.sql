CREATE TABLE xtpos.saleitemtax
(
  CONSTRAINT saleitemtax_pkey PRIMARY KEY (taxhist_id),
  CONSTRAINT saleitemtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax (tax_id),
  CONSTRAINT saleitemtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES xtpos.saleitem (saleitem_id) ON DELETE CASCADE,
  CONSTRAINT saleitemtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax (tax_id) ,
  CONSTRAINT saleitemtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype (taxtype_id)
)
INHERITS (taxhist);
ALTER TABLE xtpos.saleitemtax OWNER TO "admin";
GRANT ALL ON TABLE xtpos.saleitemtax TO "admin";
GRANT ALL ON TABLE xtpos.saleitemtax TO xtrole;