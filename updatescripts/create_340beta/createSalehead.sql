CREATE TABLE xtpos.salehead
(
  salehead_id serial NOT NULL PRIMARY KEY,
  salehead_number text NOT NULL UNIQUE,
  salehead_type character(1) NOT NULL CHECK (salehead_type IN ('S', 'Q', 'R')),
  salehead_warehous_id INTEGER NOT NULL REFERENCES whsinfo (warehous_id),
  salehead_cust_id integer NOT NULL REFERENCES custinfo (cust_id),
  salehead_time timestamp with time zone NOT NULL DEFAULT now(),
  salehead_terminal_id integer NOT NULL REFERENCES xtpos.terminal (terminal_id),
  salehead_salesrep_id INTEGER REFERENCES salesrep (salesrep_id),
  salehead_notes text,
  salehead_reghist_id integer REFERENCES xtpos.reghist (reghist_id) ON DELETE CASCADE,
  salehead_closed boolean default false,
  salehead_checknumber text,
  salehead_regdetail_id integer REFERENCES xtpos.regdetail (regdetail_id) ON DELETE CASCADE,
  salehead_ccpay_id INTEGER REFERENCES ccpay (ccpay_id),
  salehead_cashamt NUMERIC default 0,
  salehead_checkamt NUMERIC default 0
);

GRANT ALL ON xtpos.salehead TO GROUP xtrole;
GRANT ALL ON xtpos.salehead_salehead_id_seq TO GROUP xtrole;

COMMENT ON TABLE xtpos.salehead IS 'Parent record of a single sale, which might contain one or more saleitems';

COMMENT ON COLUMN xtpos.salehead.salehead_id IS 'Internal id and primary key';
COMMENT ON COLUMN xtpos.salehead.salehead_number IS 'Human-readable sale number';
COMMENT ON COLUMN xtpos.salehead.salehead_warehous_id IS 'Internal id of the Site at which this sale was made';
COMMENT ON COLUMN xtpos.salehead.salehead_terminal_id IS 'Internal id of the cash register terminal on which this sale was made';
COMMENT ON COLUMN xtpos.salehead.salehead_reghist_id IS 'Register history record';
COMMENT ON COLUMN xtpos.salehead.salehead_type IS 'Indicator of whether this sale record is an actual sale, a quote, or ';
COMMENT ON COLUMN xtpos.salehead.salehead_cust_id IS 'Sale customer id';
COMMENT ON COLUMN xtpos.salehead.salehead_time IS 'Time this sale was closed';
COMMENT ON COLUMN xtpos.salehead.salehead_closed IS 'Flag indicating that this sale has been closed';
COMMENT ON COLUMN xtpos.salehead.salehead_notes IS 'Sale notes';
COMMENT ON COLUMN xtpos.salehead.salehead_salesrep_id IS 'Internal id of the sales rep who created this sale record';
COMMENT ON COLUMN xtpos.salehead.salehead_checknumber IS 'Number of the check used to pay for this sale, if applicable';
COMMENT ON COLUMN xtpos.salehead.salehead_regdetail_id IS 'Internal id of the register detail record in which this check was marked as deposited, if any ';
COMMENT ON COLUMN xtpos.salehead.salehead_ccpay_id IS 'Internal id of the credit card payment record for this sale, if applicable';
COMMENT ON COLUMN xtpos.salehead.salehead_cashamt IS 'Amount of this sale paid in cash';
COMMENT ON COLUMN xtpos.salehead.salehead_checkamt IS 'Amount of this sale paid by check';

ALTER TABLE xtpos.salehead ADD COLUMN salehead_taxzone_id integer REFERENCES taxzone (taxzone_id);
COMMENT ON COLUMN xtpos.salehead.salehead_taxzone_id IS 'Internal id for the tax zone applied';



