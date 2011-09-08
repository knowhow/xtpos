
CREATE TABLE retail.salehead
(
  salehead_id serial NOT NULL PRIMARY KEY,
  salehead_number text NOT NULL UNIQUE,
  salehead_type character(1) NOT NULL CHECK (salehead_type IN ('S', 'Q', 'R')),
  salehead_warehous_id INTEGER NOT NULL REFERENCES whsinfo (warehous_id),
  salehead_cust_id integer NOT NULL REFERENCES custinfo (cust_id),
  salehead_time timestamp with time zone NOT NULL DEFAULT now(),
  salehead_terminal_id integer NOT NULL REFERENCES retail.terminal (terminal_id),
  salehead_salesrep_id INTEGER REFERENCES salesrep (salesrep_id),
  salehead_notes text,
  salehead_reghist_id integer REFERENCES retail.reghist (reghist_id) ON DELETE CASCADE,
  salehead_closed boolean default false
);

ALTER TABLE retail.salehead ADD COLUMN salehead_checknumber text;
ALTER TABLE retail.salehead ADD COLUMN  salehead_regdetail_id integer REFERENCES retail.regdetail (regdetail_id) ON DELETE CASCADE;
ALTER TABLE retail.salehead ADD COLUMN  salehead_ccpay_id INTEGER REFERENCES ccpay (ccpay_id);
ALTER TABLE retail.salehead ADD COLUMN  salehead_cashamt NUMERIC default 0;
ALTER TABLE retail.salehead ADD COLUMN  salehead_checkamt NUMERIC default 0;

GRANT ALL ON retail.salehead TO GROUP openmfg;
GRANT ALL ON retail.salehead_salehead_id_seq TO GROUP openmfg;
COMMENT ON TABLE retail.salehead IS 'Sale Header';
COMMENT ON COLUMN retail.salehead.salehead_id IS 'Primary key for Sale header';
COMMENT ON COLUMN retail.salehead.salehead_number IS 'Sale number';
COMMENT ON COLUMN retail.salehead.salehead_warehous_id IS 'Site id';
COMMENT ON COLUMN retail.salehead.salehead_terminal_id IS 'Terminal id';
COMMENT ON COLUMN retail.salehead.salehead_reghist_id IS 'Register history record';
COMMENT ON COLUMN retail.salehead.salehead_type IS 'Sale type';
COMMENT ON COLUMN retail.salehead.salehead_cust_id IS 'Sale customer id';
COMMENT ON COLUMN retail.salehead.salehead_time IS 'Sale time';
COMMENT ON COLUMN retail.salehead.salehead_closed IS 'Sale is closed';
COMMENT ON COLUMN retail.salehead.salehead_notes IS 'Sale notes';
COMMENT ON COLUMN retail.salehead.salehead_salesrep_id IS 'Sale sales rep id';
COMMENT ON COLUMN retail.salehead.salehead_checknumber IS 'Check number, if applicable';
COMMENT ON COLUMN retail.salehead.salehead_regdetail_id IS 'Register check clearing detail id';
COMMENT ON COLUMN retail.salehead.salehead_ccpay_id IS 'Credit card payment id';
COMMENT ON COLUMN retail.salehead.salehead_cashamt IS 'Cash amount';
COMMENT ON COLUMN retail.salehead.salehead_checkamt IS 'Check amount';



