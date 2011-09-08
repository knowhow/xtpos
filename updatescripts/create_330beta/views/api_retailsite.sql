
-- Retail Site
SELECT dropIfExists('VIEW', 'api_retailsite', 'xtpos');
CREATE VIEW xtpos.api_retailsite
AS
   SELECT 
     warehous_code AS site,
     taxzone_code AS tax_zone,
     rtlsite_quotedays AS quote_days,
     formatGlAccount(rtlsite_asset_accnt_id) AS asset,
     formatGlAccount(rtlsite_adjust_accnt_id) AS adjustment,
     formatGlAccount(rtlsite_chkclr_accnt_id) AS check_clearing
   FROM xtpos.rtlsite 
    JOIN whsinfo ON (rtlsite_warehous_id=warehous_id)
    LEFT OUTER JOIN taxzone ON (rtlsite_taxzone_id=taxzone_id)
   ORDER BY warehous_code;

GRANT ALL ON TABLE xtpos.api_retailsite TO xtrole;
COMMENT ON VIEW xtpos.api_retailsite IS 'Retail Site';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO xtpos.api_retailsite DO INSTEAD

  INSERT INTO xtpos.rtlsite (
    rtlsite_warehous_id,
    rtlsite_quotedays,
    rtlsite_asset_accnt_id,
    rtlsite_adjust_accnt_id,
    rtlsite_chkclr_accnt_id,
    rtlsite_taxzone_id)
  VALUES (
    getWarehousId(NEW.site,'ALL'),
    COALESCE(NEW.quote_days,0),
    getGlAccntId(NEW.asset),
    getGlAccntId(NEW.adjustment),
    getGlAccntId(NEW.check_clearing),
    getTaxzoneId(NEW.tax_zone));

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO xtpos.api_retailsite DO INSTEAD

  UPDATE xtpos.rtlsite SET
    rtlsite_quotedays=NEW.quote_days,
    rtlsite_asset_accnt_id=getGlAccntId(NEW.asset),
    rtlsite_adjust_accnt_id=getGlAccntId(NEW.adjustment),
    rtlsite_chkclr_accnt_id=getGlAccntId(NEW.check_clearing) ,
    rtlsite_taxzone_id=getTaxzoneId(NEW.tax_zone)
  WHERE (rtlsite_warehous_id=getWarehousId(OLD.site,'ALL'));
       
CREATE OR REPLACE RULE "_DELETE" AS
    ON DELETE TO xtpos.api_retailsite DO INSTEAD

  DELETE FROM xtpos.rtlsite WHERE (rtlsite_warehous_id=getWarehousId(OLD.site,'ALL'));


