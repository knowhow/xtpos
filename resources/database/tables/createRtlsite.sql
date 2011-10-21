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

CREATE TABLE xtpos.rtlsite
(
  rtlsite_id              SERIAL PRIMARY KEY,
  rtlsite_warehous_id     INTEGER NOT NULL UNIQUE REFERENCES whsinfo (warehous_id),
  rtlsite_quotedays       INTEGER NOT NULL DEFAULT 1,
  rtlsite_asset_accnt_id  INTEGER NOT NULL REFERENCES accnt (accnt_id),
  rtlsite_adjust_accnt_id INTEGER NOT NULL REFERENCES accnt (accnt_id),
  rtlsite_chkclr_accnt_id INTEGER NOT NULL REFERENCES accnt (accnt_id)
);

GRANT ALL ON xtpos.rtlsite TO xtrole;
GRANT ALL ON xtpos.rtlsite_rtlsite_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.rtlsite IS 'Information Retail Sites need to carry in addition to the standard Site (whsinfo) data';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_warehous_id IS 'Internal id of the Site to which this additional data apply';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_quotedays IS 'Number of days after which a quote created at this Retail Site expires';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_asset_accnt_id IS 'Internal id of the G/L asset account assigned to this Retail Site';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_adjust_accnt_id IS 'Internal id of the G/L adjustment account assigned to this Retail Site';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_chkclr_accnt_id IS 'Internal id of the G/L check clearning account assigned to this Retail Site';

ALTER TABLE xtpos.rtlsite ADD COLUMN rtlsite_taxzone_id INTEGER REFERENCES taxzone (taxzone_id);
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_taxzone_id IS 'Internal id of the tax zone applied to this Retail Site';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

