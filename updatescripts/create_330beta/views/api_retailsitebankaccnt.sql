
-- Retail Site Bank Account
SELECT dropIfExists('VIEW', 'api_retailsitebankaccnt', 'xtpos');
CREATE VIEW xtpos.api_retailsitebankaccnt
AS
   SELECT 
     warehous_code AS site,
     bankaccnt_name AS bank_account
   FROM xtpos.rtlsitebnkacct, xtpos.rtlsite, bankaccnt, whsinfo
   WHERE ((rtlsite_id=rtlsitebnkacct_rtlsite_id)
   AND (rtlsitebnkacct_bankaccnt_id=bankaccnt_id)
   AND (rtlsite_warehous_id=warehous_id));

GRANT ALL ON TABLE xtpos.api_retailsitebankaccnt TO xtrole;
COMMENT ON VIEW xtpos.api_retailsitebankaccnt IS 'Retail Site Bank Account';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO xtpos.api_retailsitebankaccnt DO INSTEAD

  INSERT INTO xtpos.rtlsitebnkacct (
    rtlsitebnkacct_rtlsite_id,
    rtlsitebnkacct_bankaccnt_id)
  VALUES (
    xtpos.getRtlsiteId(NEW.site),
    getBankAccntId(NEW.bank_account));

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO xtpos.api_retailsitebankaccnt DO INSTEAD

  UPDATE xtpos.rtlsitebnkacct SET
    rtlsitebnkacct_bankaccnt_id=getBankaccntId(NEW.bank_account)
  WHERE ((rtlsitebnkacct_rtlsite_id=xtpos.getRtlsiteId(OLD.site))
  AND (rtlsitebnkacct_bankaccnt_id=getBankAccntId(OLD.bank_account)));
    
           
CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO xtpos.api_retailsitebankaccnt DO INSTEAD

  DELETE FROM xtpos.rtlsitebnkacct 
  WHERE ((rtlsitebnkacct_rtlsite_id=xtpos.getRtlsiteId(OLD.site))
  AND (rtlsitebnkacct_bankaccnt_id=getBankAccntId(OLD.bank_account)));


