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

CREATE TABLE xtpos.terminal
(
   terminal_id serial PRIMARY KEY, 
   terminal_number text NOT NULL UNIQUE
);

GRANT ALL ON xtpos.terminal TO xtrole;
GRANT ALL ON xtpos.terminal_terminal_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.terminal IS 'This table holds a list of cash register terminals defined for the xtpos package in xTuple ERP';
COMMENT ON COLUMN xtpos.terminal.terminal_id IS 'Terminal internal id and primary key';
COMMENT ON COLUMN xtpos.terminal.terminal_number IS 'A human-readable short name for this cash register terminal, which must be unique for this database. If one database is shared by multiple stores, terminal numbers could include a prefix or suffix that distinguishes between those different stores.';

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

