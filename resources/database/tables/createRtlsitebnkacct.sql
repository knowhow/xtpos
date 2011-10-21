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


CREATE TABLE xtpos.rtlsitebnkacct
(
   rtlsitebnkacct_id           SERIAL PRIMARY KEY,
   rtlsitebnkacct_rtlsite_id   INTEGER NOT NULL REFERENCES xtpos.rtlsite (rtlsite_id) ON DELETE CASCADE,
   rtlsitebnkacct_bankaccnt_id INTEGER NOT NULL REFERENCES bankaccnt (bankaccnt_id)
) ;

ALTER TABLE xtpos.rtlsitebnkacct ADD UNIQUE (rtlsitebnkacct_rtlsite_id,rtlsitebnkacct_bankaccnt_id);

GRANT ALL ON xtpos.rtlsitebnkacct TO xtrole;
GRANT ALL ON xtpos.rtlsitebnkacct_rtlsitebnkacct_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.rtlsitebnkacct IS 'List of which Bank Accounts may be used for cash register maintenance transactions by the various Retail Sites';

COMMENT ON COLUMN xtpos.rtlsitebnkacct.rtlsitebnkacct_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.rtlsitebnkacct.rtlsitebnkacct_rtlsite_id IS 'Internal id of the Retail Site';
COMMENT ON COLUMN xtpos.rtlsitebnkacct.rtlsitebnkacct_bankaccnt_id IS 'Internal id of the Bank Account';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

