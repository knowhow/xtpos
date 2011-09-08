
-- Retail Site Terminal
SELECT dropIfExists('VIEW', 'api_retailsiteterminal', 'xtpos');
CREATE VIEW xtpos.api_retailsiteterminal
AS
   SELECT 
     warehous_code AS site,
     terminal_number AS terminal
   FROM xtpos.rtlsite
     JOIN xtpos.rtlsiteterm ON (rtlsite_id=rtlsiteterm_rtlsite_id)
     JOIN xtpos.terminal ON (rtlsiteterm_terminal_id=terminal_id)
     JOIN whsinfo ON (rtlsite_warehous_id=warehous_id);

GRANT ALL ON TABLE xtpos.api_retailsiteterminal TO xtrole;
COMMENT ON VIEW xtpos.api_retailsiteterminal IS 'Retail Site Terminal';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO xtpos.api_retailsiteterminal DO INSTEAD

  INSERT INTO xtpos.rtlsiteterm (
    rtlsiteterm_rtlsite_id,
    rtlsiteterm_terminal_id)
  VALUES (
    xtpos.getRtlsiteId(NEW.site),
    xtpos.getTerminalId(NEW.terminal));

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO xtpos.api_retailsiteterminal DO INSTEAD

  UPDATE xtpos.rtlsiteterm SET
    rtlsiteterm_terminal_id=xtpos.getTerminalId(NEW.terminal)
  WHERE ((rtlsiteterm_rtlsite_id=xtpos.getRtlsiteId(OLD.site))
  AND (rtlsiteterm_terminal_id=xtpos.getTerminalId(OLD.terminal)));
    
           
CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO xtpos.api_retailsiteterminal DO INSTEAD

  DELETE FROM xtpos.rtlsiteterm
  WHERE ((rtlsiteterm_rtlsite_id=xtpos.getRtlsiteId(OLD.site))
  AND (rtlsiteterm_terminal_id=xtpos.getTerminalId(OLD.terminal)));


