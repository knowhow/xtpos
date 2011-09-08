CREATE TABLE xtpos.rtlsitebnkacct
(
   rtlsitebnkacct_id           SERIAL PRIMARY KEY,
   rtlsitebnkacct_rtlsite_id   INTEGER NOT NULL REFERENCES xtpos.rtlsite (rtlsite_id) ON DELETE CASCADE,
   rtlsitebnkacct_bankaccnt_id INTEGER NOT NULL REFERENCES bankaccnt (bankaccnt_id)
) ;

ALTER TABLE xtpos.rtlsitebnkacct ADD UNIQUE (rtlsitebnkacct_rtlsite_id,rtlsitebnkacct_bankaccnt_id);

GRANT ALL ON xtpos.rtlsitebnkacct TO xtrole;
GRANT ALL ON xtpos.rtlsitebnkacct_rtlsitebnkacct_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.rtlsitebnkacct IS 'List of which Bank Accounts may be used for cash register maintenance transactions by the various Retail Sites';

COMMENT ON COLUMN xtpos.rtlsitebnkacct.rtlsitebnkacct_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.rtlsitebnkacct.rtlsitebnkacct_rtlsite_id IS 'Internal id of the Retail Site';
COMMENT ON COLUMN xtpos.rtlsitebnkacct.rtlsitebnkacct_bankaccnt_id IS 'Internal id of the Bank Account';
