CREATE SEQUENCE retail.sale_number_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 100000
  CACHE 1;
ALTER TABLE retail.sale_number_seq OWNER TO openmfg;

GRANT ALL ON retail.sale_number_seq TO openmfg;