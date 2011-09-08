CREATE TABLE retail.terminal
(
   terminal_id serial PRIMARY KEY, 
   terminal_number text NOT NULL UNIQUE
);


GRANT ALL ON retail.terminal TO openmfg;
COMMENT ON COLUMN retail.terminal.terminal_id IS 'Terminal primary key';
COMMENT ON COLUMN retail.terminal.terminal_number IS 'Terminal number';
COMMENT ON TABLE retail.terminal IS 'Terminal';

GRANT ALL ON retail.terminal_terminal_id_seq TO GROUP openmfg;