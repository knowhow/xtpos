
CREATE TABLE retail.regdetail
(
  regdetail_id serial NOT NULL PRIMARY KEY,
  regdetail_reghist_id integer NOT NULL REFERENCES retail.reghist (reghist_id) ON DELETE CASCADE, 
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
  regdetail_username text DEFAULT current_user
);
GRANT ALL ON retail.regdetail TO openmfg;
GRANT ALL ON retail.regdetail_regdetail_id_seq TO GROUP openmfg;
COMMENT ON TABLE retail.regdetail IS 'Cash register detail';
COMMENT ON COLUMN retail.regdetail.regdetail_id IS 'Cash register detail primary key';
COMMENT ON COLUMN retail.regdetail.regdetail_reghist_id IS 'Cash register detail cash register history id';
COMMENT ON COLUMN retail.regdetail.regdetail_type IS 'Cash register detail type';
COMMENT ON COLUMN retail.regdetail.regdetail_startbal IS 'Cash register detail starting balance';
COMMENT ON COLUMN retail.regdetail.regdetail_cashslsamt IS 'Cash register detail cash sales amount processed between current transaction and previous detail transaction';
COMMENT ON COLUMN retail.regdetail.regdetail_bankaccnt_id IS 'Cash register detail transfer bank account id';
COMMENT ON COLUMN retail.regdetail.regdetail_transferamt IS 'Cash register detail transfer amount to register';
COMMENT ON COLUMN retail.regdetail.regdetail_adjustamt IS 'Cash register detail adjustment amount to register';
COMMENT ON COLUMN retail.regdetail.regdetail_endbal IS 'Cash register detail ending balance';
COMMENT ON COLUMN retail.regdetail.regdetail_time IS 'Cash register detail time';
COMMENT ON COLUMN retail.regdetail.regdetail_depchks IS 'Cash register detail deposit checks flag';
COMMENT ON COLUMN retail.regdetail.regdetail_username IS 'Cash register detail user name';
COMMENT ON COLUMN retail.regdetail.regdetail_username IS 'Cash register detail notes';

ALTER TABLE retail.regdetail ADD COLUMN regdetail_journalnumber INTEGER;
COMMENT ON COLUMN retail.regdetail.regdetail_journalnumber IS 'Cash register detail journal number';
