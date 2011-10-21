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

