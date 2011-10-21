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

CREATE TABLE xtpos.reghist
(
  reghist_id serial PRIMARY KEY,
  reghist_warehous_id integer NOT NULL REFERENCES whsinfo (warehous_id),
  reghist_terminal_id integer NOT NULL REFERENCES xtpos.terminal (terminal_id),
  reghist_taxauth_id integer REFERENCES taxauth (taxauth_id),
  reghist_asset_accnt_id integer NOT NULL REFERENCES accnt (accnt_id),
  reghist_adjust_accnt_id integer NOT NULL REFERENCES accnt (accnt_id),
  reghist_chkclr_accnt_id integer NOT NULL REFERENCES accnt (accnt_id),
  reghist_open boolean NOT NULL DEFAULT true,
  reghist_open_time timestamp with time zone NOT NULL DEFAULT now(),
  reghist_close_time timestamp with time zone
);
GRANT ALL ON xtpos.reghist TO xtrole;
GRANT ALL ON xtpos.reghist_reghist_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.reghist IS 'Cash Register History';

COMMENT ON COLUMN xtpos.reghist.reghist_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.reghist.reghist_warehous_id IS 'Internal id of the site for this cash register';
COMMENT ON COLUMN xtpos.reghist.reghist_terminal_id IS 'Internal id of the cash register terminal';
COMMENT ON COLUMN xtpos.reghist.reghist_taxauth_id IS 'Internal id of the tax authority applicable to this cash register';
COMMENT ON COLUMN xtpos.reghist.reghist_asset_accnt_id IS 'Internal id of the G/L asset account assigned to this cash register';
COMMENT ON COLUMN xtpos.reghist.reghist_adjust_accnt_id IS 'Internal id of the G/L adjustment account assigned to this cash register';
COMMENT ON COLUMN xtpos.reghist.reghist_chkclr_accnt_id IS 'Internal id of the G/L clearing account assigned to this cash register';
COMMENT ON COLUMN xtpos.reghist.reghist_open IS 'Flag indicating whether this cash register was open at the time of this transaction';
COMMENT ON COLUMN xtpos.reghist.reghist_open_time IS 'Time this cash register was last opened when this transaction occurred';
COMMENT ON COLUMN xtpos.reghist.reghist_close_time IS 'Time this cash register was last closed when this transaction occurred';

ALTER TABLE xtpos.reghist DROP CONSTRAINT reghist_reghist_taxauth_id_fkey;

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

