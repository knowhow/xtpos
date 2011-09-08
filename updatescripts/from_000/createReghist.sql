
CREATE TABLE retail.reghist
(
  reghist_id serial PRIMARY KEY,
  reghist_warehous_id integer NOT NULL REFERENCES whsinfo (warehous_id),
  reghist_terminal_id integer NOT NULL REFERENCES retail.terminal (terminal_id),
  reghist_taxauth_id integer REFERENCES taxauth (taxauth_id),
  reghist_asset_accnt_id integer NOT NULL REFERENCES accnt (accnt_id),
  reghist_adjust_accnt_id integer NOT NULL REFERENCES accnt (accnt_id),
  reghist_chkclr_accnt_id integer NOT NULL REFERENCES accnt (accnt_id),
  reghist_open boolean NOT NULL DEFAULT true,
  reghist_open_time timestamp with time zone NOT NULL DEFAULT now(),
  reghist_close_time timestamp with time zone
);
GRANT ALL ON retail.reghist TO openmfg;
GRANT ALL ON retail.reghist_reghist_id_seq TO GROUP openmfg;
COMMENT ON TABLE retail.reghist IS 'Cash Register History';
COMMENT ON COLUMN retail.reghist.reghist_id IS 'Cash register history primary key';
COMMENT ON COLUMN retail.reghist.reghist_warehous_id IS 'Cash register sale warehouse (retail site) id';
COMMENT ON COLUMN retail.reghist.reghist_terminal_id IS 'Cash register terminal id';
COMMENT ON COLUMN retail.reghist.reghist_taxauth_id IS 'Cash register tax authority id';
COMMENT ON COLUMN retail.reghist.reghist_asset_accnt_id IS 'Cash register asset account id';
COMMENT ON COLUMN retail.reghist.reghist_adjust_accnt_id IS 'Cash register adjustment account id';
COMMENT ON COLUMN retail.reghist.reghist_open IS 'Cash register open flag';
COMMENT ON COLUMN retail.reghist.reghist_open_time IS 'Cash register open time';
COMMENT ON COLUMN retail.reghist.reghist_close_time IS 'Cash register close time';
COMMENT ON COLUMN retail.reghist.reghist_adjust_accnt_id IS 'Cash register check clearing account id';

