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

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

