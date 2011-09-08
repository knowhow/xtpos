CREATE TABLE xtpos.regdetail
(
  regdetail_id serial NOT NULL PRIMARY KEY,
  regdetail_reghist_id integer NOT NULL REFERENCES xtpos.reghist (reghist_id) ON DELETE CASCADE, 
  regdetail_type character(1) NOT NULL CHECK (regdetail_type IN ('O','A','C')),
  regdetail_startbal numeric NOT NULL DEFAULT 0,
  regdetail_cashslsamt numeric NOT NULL DEFAULT 0, 
  regdetail_bankaccnt_id integer REFERENCES bankaccnt (bankaccnt_id), 
  regdetail_transferamt numeric NOT NULL DEFAULT 0,
  regdetail_adjustamt numeric NOT NULL DEFAULT 0, 
  regdetail_endbal numeric NOT NULL DEFAULT 0,
  regdetail_depchks boolean NOT NULL DEFAULT false,
  regdetail_notes TEXT,
  regdetail_time timestamp with time zone DEFAULT now(),
  regdetail_username text DEFAULT current_user,
  regdetail_journalnumber INTEGER
);

GRANT ALL ON xtpos.regdetail TO openmfg;
GRANT ALL ON xtpos.regdetail_regdetail_id_seq TO GROUP openmfg;

COMMENT ON TABLE xtpos.regdetail IS 'Cash register detail';
COMMENT ON COLUMN xtpos.regdetail.regdetail_id IS 'Cash register detail internal id and primary key';
COMMENT ON COLUMN xtpos.regdetail.regdetail_reghist_id IS 'Cash register detail cash register history id';
COMMENT ON COLUMN xtpos.regdetail.regdetail_type IS 'Indicates whether this transaction opened, closed, or adjusted the drawer value of a cash register';
COMMENT ON COLUMN xtpos.regdetail.regdetail_startbal IS 'Cash register detail starting balance';
COMMENT ON COLUMN xtpos.regdetail.regdetail_cashslsamt IS 'Cash register detail cash sales amount processed between current transaction and previous detail transaction';
COMMENT ON COLUMN xtpos.regdetail.regdetail_bankaccnt_id IS 'Cash register detail transfer bank account id';
COMMENT ON COLUMN xtpos.regdetail.regdetail_transferamt IS 'The amount (in base currency) transferred into or out of this register';
COMMENT ON COLUMN xtpos.regdetail.regdetail_adjustamt IS 'The amount (in base currency) by which the drawer value of this register was adjusted';
COMMENT ON COLUMN xtpos.regdetail.regdetail_endbal IS 'Cash register detail ending balance';
COMMENT ON COLUMN xtpos.regdetail.regdetail_time IS 'Cash register detail time';
COMMENT ON COLUMN xtpos.regdetail.regdetail_depchks IS 'Flag indicating whether checks were deposited as part of this transaction';
COMMENT ON COLUMN xtpos.regdetail.regdetail_username IS 'The name of the user who performed this transaction';
COMMENT ON COLUMN xtpos.regdetail.regdetail_notes IS 'Cash register detail notes';
COMMENT ON COLUMN xtpos.regdetail.regdetail_journalnumber IS 'The journal number used to record changes to the G/L for this transaction';
