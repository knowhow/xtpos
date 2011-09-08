
CREATE TABLE retail.rtlsitebnkacct
(
   rtlsitebnkacct_id serial PRIMARY KEY, --Retail site bank account primary key
   rtlsitebnkacct_rtlsite_id integer NOT NULL REFERENCES retail.rtlsite (rtlsite_id) ON DELETE CASCADE,  --Retail site retail site id
   rtlsitebnkacct_bankaccnt_id integer NOT NULL REFERENCES bankaccnt (bankaccnt_id) --Retail site bank account bank account id
) ;

ALTER TABLE retail.rtlsitebnkacct ADD UNIQUE (rtlsitebnkacct_rtlsite_id,rtlsitebnkacct_bankaccnt_id);

GRANT ALL ON retail.rtlsitebnkacct TO openmfg;
GRANT ALL ON retail.rtlsitebnkacct_rtlsitebnkacct_id_seq TO GROUP openmfg;
COMMENT ON COLUMN retail.rtlsitebnkacct.rtlsitebnkacct_id IS 'Retail site bank account primary key';
COMMENT ON COLUMN retail.rtlsitebnkacct.rtlsitebnkacct_rtlsite_id IS 'Retail site retail site id';
COMMENT ON COLUMN retail.rtlsitebnkacct.rtlsitebnkacct_bankaccnt_id IS 'Retail site bank account bank account id';
COMMENT ON TABLE retail.rtlsitebnkacct IS 'Retail site bank account';
