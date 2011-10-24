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

CREATE TABLE xtpos.regdetail
(
  regdetail_id serial NOT NULL PRIMARY KEY,
  regdetail_reghist_id integer NOT NULL REFERENCES xtpos.reghist (reghist_id) ON DELETE CASCADE, 
  regdetail_type character(1) NOT NULL CHECK (regdetail_type IN ('O','A','C')),
  regdetail_startbal numeric NOT NULL DEFAULT 0,
  regdetail_cashslsamt numeric NOT NULL DEFAULT 0, 
  regdetail_bankaccnt_id integer REFERENCES bankaccnt (bankaccnt_id), 
  regdetail_transferamt numeric NOT NULL DEFAULT 0,
  regdetail_adjustamt numeric NOT NULL DEFAULT 0, 
  regdetail_endbal numeric NOT NULL DEFAULT 0,
  regdetail_depchks boolean NOT NULL DEFAULT false,
  regdetail_notes TEXT,
  regdetail_time timestamp with time zone DEFAULT now(),
  regdetail_username text DEFAULT current_user,
  regdetail_journalnumber INTEGER
);

GRANT ALL ON xtpos.regdetail TO xtrole;
GRANT ALL ON xtpos.regdetail_regdetail_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.regdetail IS 'Cash register detail';
COMMENT ON COLUMN xtpos.regdetail.regdetail_id IS 'Cash register detail internal id and primary key';
COMMENT ON COLUMN xtpos.regdetail.regdetail_reghist_id IS 'Cash register detail cash register history id';
COMMENT ON COLUMN xtpos.regdetail.regdetail_type IS 'Indicates whether this transaction opened, closed, or adjusted the drawer value of a cash register';
COMMENT ON COLUMN xtpos.regdetail.regdetail_startbal IS 'Cash register detail starting balance';
COMMENT ON COLUMN xtpos.regdetail.regdetail_cashslsamt IS 'Cash register detail cash sales amount processed between current transaction and previous detail transaction';
COMMENT ON COLUMN xtpos.regdetail.regdetail_bankaccnt_id IS 'Cash register detail transfer bank account id';
COMMENT ON COLUMN xtpos.regdetail.regdetail_transferamt IS 'The amount (in base currency) transferred into or out of this register';
COMMENT ON COLUMN xtpos.regdetail.regdetail_adjustamt IS 'The amount (in base currency) by which the drawer value of this register was adjusted';
COMMENT ON COLUMN xtpos.regdetail.regdetail_endbal IS 'Cash register detail ending balance';
COMMENT ON COLUMN xtpos.regdetail.regdetail_time IS 'Cash register detail time';
COMMENT ON COLUMN xtpos.regdetail.regdetail_depchks IS 'Flag indicating whether checks were deposited as part of this transaction';
COMMENT ON COLUMN xtpos.regdetail.regdetail_username IS 'The name of the user who performed this transaction';
COMMENT ON COLUMN xtpos.regdetail.regdetail_notes IS 'Cash register detail notes';
COMMENT ON COLUMN xtpos.regdetail.regdetail_journalnumber IS 'The journal number used to record changes to the G/L for this transaction';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);


