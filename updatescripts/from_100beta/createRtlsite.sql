CREATE TABLE xtpos.rtlsite
(
  rtlsite_id              SERIAL PRIMARY KEY,
  rtlsite_warehous_id     INTEGER NOT NULL UNIQUE REFERENCES whsinfo (warehous_id),
  rtlsite_quotedays       INTEGER NOT NULL DEFAULT 1,
  rtlsite_asset_accnt_id  INTEGER NOT NULL REFERENCES accnt (accnt_id),
  rtlsite_adjust_accnt_id INTEGER NOT NULL REFERENCES accnt (accnt_id),
  rtlsite_chkclr_accnt_id INTEGER NOT NULL REFERENCES accnt (accnt_id)
);

GRANT ALL ON xtpos.rtlsite TO openmfg;
GRANT ALL ON xtpos.rtlsite_rtlsite_id_seq TO GROUP openmfg;

COMMENT ON TABLE xtpos.rtlsite IS 'Information Retail Sites need to carry in addition to the standard Site (whsinfo) data';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_warehous_id IS 'Internal id of the Site to which this additional data apply';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_quotedays IS 'Number of days after which a quote created at this Retail Site expires';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_asset_accnt_id IS 'Internal id of the G/L asset account assigned to this Retail Site';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_adjust_accnt_id IS 'Internal id of the G/L adjustment account assigned to this Retail Site';
COMMENT ON COLUMN xtpos.rtlsite.rtlsite_chkclr_accnt_id IS 'Internal id of the G/L check clearning account assigned to this Retail Site';
