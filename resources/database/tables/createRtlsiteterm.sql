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

CREATE TABLE xtpos.rtlsiteterm
(
   rtlsiteterm_id serial PRIMARY KEY, 
   rtlsiteterm_rtlsite_id integer NOT NULL REFERENCES xtpos.rtlsite (rtlsite_id) ON DELETE CASCADE, 
   rtlsiteterm_terminal_id integer NOT NULL UNIQUE REFERENCES xtpos.terminal (terminal_id)
);

GRANT ALL ON xtpos.rtlsiteterm TO xtrole;
GRANT ALL ON xtpos.rtlsiteterm_rtlsiteterm_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.rtlsiteterm IS 'Association between a particular Cash Register Terminal and a particular Retail Site';

COMMENT ON COLUMN xtpos.rtlsiteterm.rtlsiteterm_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.rtlsiteterm.rtlsiteterm_rtlsite_id IS 'Internal id of the Retail Site';
COMMENT ON COLUMN xtpos.rtlsiteterm.rtlsiteterm_terminal_id IS 'Internal id of the Cash Register Terminal';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

