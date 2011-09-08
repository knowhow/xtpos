CREATE TABLE xtpos.rtlsiteterm
(
   rtlsiteterm_id serial PRIMARY KEY, 
   rtlsiteterm_rtlsite_id integer NOT NULL REFERENCES xtpos.rtlsite (rtlsite_id) ON DELETE CASCADE, 
   rtlsiteterm_terminal_id integer NOT NULL UNIQUE REFERENCES xtpos.terminal (terminal_id)
);

GRANT ALL ON xtpos.rtlsiteterm TO openmfg;
GRANT ALL ON xtpos.rtlsiteterm_rtlsiteterm_id_seq TO GROUP openmfg;

COMMENT ON TABLE xtpos.rtlsiteterm IS 'Association between a particular Cash Register Terminal and a particular Retail Site';

COMMENT ON COLUMN xtpos.rtlsiteterm.rtlsiteterm_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.rtlsiteterm.rtlsiteterm_rtlsite_id IS 'Internal id of the Retail Site';
COMMENT ON COLUMN xtpos.rtlsiteterm.rtlsiteterm_terminal_id IS 'Internal id of the Cash Register Terminal';
