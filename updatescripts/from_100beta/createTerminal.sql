CREATE TABLE xtpos.terminal
(
   terminal_id serial PRIMARY KEY, 
   terminal_number text NOT NULL UNIQUE
);

GRANT ALL ON xtpos.terminal TO openmfg;
GRANT ALL ON xtpos.terminal_terminal_id_seq TO GROUP openmfg;

COMMENT ON TABLE xtpos.terminal IS 'This table holds a list of cash register terminals defined for the xtpos package in xTuple ERP';
COMMENT ON COLUMN xtpos.terminal.terminal_id IS 'Terminal internal id and primary key';
COMMENT ON COLUMN xtpos.terminal.terminal_number IS 'A human-readable short name for this cash register terminal, which must be unique for this database. If one database is shared by multiple stores, terminal numbers could include a prefix or suffix that distinguishes between those different stores.';
