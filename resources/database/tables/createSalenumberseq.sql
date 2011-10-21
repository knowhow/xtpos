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

CREATE SEQUENCE xtpos.sale_number_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 100000
  CACHE 1;

GRANT ALL ON xtpos.sale_number_seq TO xtrole;

$$) 
WHERE (u2.knowhow_package_version('xtpos') < 30703);

