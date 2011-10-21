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

