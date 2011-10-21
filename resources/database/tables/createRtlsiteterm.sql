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

