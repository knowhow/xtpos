
CREATE TABLE retail.rtlsiteterm
(
   rtlsiteterm_id serial PRIMARY KEY, 
   rtlsiteterm_rtlsite_id integer NOT NULL REFERENCES retail.rtlsite (rtlsite_id) ON DELETE CASCADE, 
   rtlsiteterm_terminal_id integer NOT NULL UNIQUE REFERENCES retail.terminal (terminal_id)
);

GRANT ALL ON retail.rtlsiteterm TO openmfg;
GRANT ALL ON retail.rtlsiteterm_rtlsiteterm_id_seq TO GROUP openmfg;
COMMENT ON COLUMN retail.rtlsiteterm.rtlsiteterm_id IS 'Retail site terminal primary key';
COMMENT ON COLUMN retail.rtlsiteterm.rtlsiteterm_rtlsite_id IS 'Retail site terminal site id';
COMMENT ON COLUMN retail.rtlsiteterm.rtlsiteterm_terminal_id IS 'Retail site terminal id';
COMMENT ON TABLE retail.rtlsiteterm IS 'Retail site terminal';
