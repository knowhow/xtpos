
CREATE TABLE retail.rtlsite
(
   rtlsite_id serial PRIMARY KEY, -- Retail site primary key
   rtlsite_warehous_id integer NOT NULL REFERENCES whsinfo (warehous_id), --Retail site warehouse id
   rtlsite_quotedays integer NOT NULL DEFAULT 1, --Retail site number of days until a quote expires
   rtlsite_asset_accnt_id integer NOT NULL REFERENCES accnt (accnt_id), --Retail site asset account id 
   rtlsite_adjust_accnt_id integer NOT NULL REFERENCES accnt (accnt_id) --Retail site adjustment account id
)
;
GRANT ALL ON retail.rtlsite TO openmfg;
GRANT ALL ON retail.rtlsite_rtlsite_id_seq TO GROUP openmfg;
COMMENT ON COLUMN retail.rtlsite.rtlsite_id IS 'Retail site primary key';
COMMENT ON COLUMN retail.rtlsite.rtlsite_warehous_id IS 'Retail site warehouse id';
COMMENT ON COLUMN retail.rtlsite.rtlsite_quotedays IS 'Retail site number of days until a quote expires';
COMMENT ON COLUMN retail.rtlsite.rtlsite_asset_accnt_id IS 'Retail site asset account id';
COMMENT ON COLUMN retail.rtlsite.rtlsite_adjust_accnt_id IS 'Retail site adjustment account id';
COMMENT ON TABLE retail.rtlsite IS 'Retail site';

ALTER TABLE retail.rtlsite ADD UNIQUE (rtlsite_warehous_id);

ALTER TABLE retail.rtlsite ADD COLUMN rtlsite_chkclr_accnt_id integer NOT NULL REFERENCES accnt (accnt_id);
COMMENT ON COLUMN retail.rtlsite.rtlsite_adjust_accnt_id IS 'Retail site check clearing account id';
