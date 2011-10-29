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

CREATE TABLE xtpos.salehead
(
  salehead_id serial NOT NULL PRIMARY KEY,
  salehead_number text NOT NULL UNIQUE,
  salehead_type character(1) NOT NULL CHECK (salehead_type IN ('S', 'Q', 'R')),
  salehead_warehous_id INTEGER NOT NULL REFERENCES whsinfo (warehous_id),
  salehead_cust_id integer NOT NULL REFERENCES custinfo (cust_id),
  salehead_time timestamp with time zone NOT NULL DEFAULT now(),
  salehead_terminal_id integer NOT NULL REFERENCES xtpos.terminal (terminal_id),
  salehead_salesrep_id INTEGER REFERENCES salesrep (salesrep_id),
  salehead_notes text,
  salehead_reghist_id integer REFERENCES xtpos.reghist (reghist_id) ON DELETE CASCADE,
  salehead_closed boolean default false,
  salehead_checknumber text,
  salehead_regdetail_id integer REFERENCES xtpos.regdetail (regdetail_id) ON DELETE CASCADE,
  salehead_ccpay_id INTEGER REFERENCES ccpay (ccpay_id),
  salehead_cashamt NUMERIC default 0,
  salehead_checkamt NUMERIC default 0
);

GRANT ALL ON xtpos.salehead TO GROUP xtrole;
GRANT ALL ON xtpos.salehead_salehead_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.salehead IS 'Parent record of a single sale, which might contain one or more saleitems';

COMMENT ON COLUMN xtpos.salehead.salehead_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.salehead.salehead_number IS 'Human-readable sale number';
COMMENT ON COLUMN xtpos.salehead.salehead_warehous_id IS 'Internal id of the Site at which this sale was made';
COMMENT ON COLUMN xtpos.salehead.salehead_terminal_id IS 'Internal id of the cash register terminal on which this sale was made';
COMMENT ON COLUMN xtpos.salehead.salehead_reghist_id IS 'Register history record';
COMMENT ON COLUMN xtpos.salehead.salehead_type IS 'Indicator of whether this sale record is an actual sale, a quote, or ';
COMMENT ON COLUMN xtpos.salehead.salehead_cust_id IS 'Sale customer id';
COMMENT ON COLUMN xtpos.salehead.salehead_time IS 'Time this sale was closed';
COMMENT ON COLUMN xtpos.salehead.salehead_closed IS 'Flag indicating that this sale has been closed';
COMMENT ON COLUMN xtpos.salehead.salehead_notes IS 'Sale notes';
COMMENT ON COLUMN xtpos.salehead.salehead_salesrep_id IS 'Internal id of the sales rep who created this sale record';
COMMENT ON COLUMN xtpos.salehead.salehead_checknumber IS 'Number of the check used to pay for this sale, if applicable';
COMMENT ON COLUMN xtpos.salehead.salehead_regdetail_id IS 'Internal id of the register detail record in which this check was marked as deposited, if any ';
COMMENT ON COLUMN xtpos.salehead.salehead_ccpay_id IS 'Internal id of the credit card payment record for this sale, if applicable';
COMMENT ON COLUMN xtpos.salehead.salehead_cashamt IS 'Amount of this sale paid in cash';
COMMENT ON COLUMN xtpos.salehead.salehead_checkamt IS 'Amount of this sale paid by check';

ALTER TABLE xtpos.salehead ADD COLUMN salehead_taxzone_id integer REFERENCES taxzone (taxzone_id);
COMMENT ON COLUMN xtpos.salehead.salehead_taxzone_id IS 'Internal id for the tax zone applied';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30702);


