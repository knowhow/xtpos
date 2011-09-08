CREATE OR REPLACE FUNCTION moveDataFromRetailToXtpos() RETURNS BOOL AS $$
DECLARE
  _r    RECORD;
  _hadretail    BOOL := FALSE;
BEGIN
  IF (SELECT rolsuper FROM pg_roles WHERE (rolname=CURRENT_USER)) THEN
    INSERT INTO usrpriv (usrpriv_priv_id, usrpriv_username)
           SELECT pkgitem_item_id, CURRENT_USER
           FROM pkgitem JOIN pkghead ON (pkgitem_pkghead_id=pkghead_id)
           WHERE ((pkghead_name='xtpos')
              AND (pkgitem_type='P'));
  END IF;

  ALTER TABLE xtpos.saleitem DISABLE TRIGGER saleitemStatusCheck;

  FOR _r IN SELECT *
            FROM pkgitem JOIN pkghead ON (pkgitem_pkghead_id=pkghead_id)
            WHERE ((pkghead_name='retail')
               AND (pkgitem_type='T')) LOOP
    EXECUTE 'INSERT INTO xtpos.' || _r.pkgitem_name ||
            ' SELECT * FROM retail.' || _r.pkgitem_name || ';';
    _hadretail := TRUE;
  END LOOP;

  ALTER TABLE xtpos.saleitem  ENABLE TRIGGER saleitemStatusCheck;

  IF (_hadretail) THEN
    PERFORM SETVAL('xtpos.sale_number_seq', last_value)
    FROM retail.sale_number_seq;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

SELECT moveDataFromRetailToXtpos();
DROP FUNCTION moveDataFromRetailToXtpos();

CREATE OR REPLACE FUNCTION fixSerial() RETURNS INTEGER AS $$
DECLARE
  _counter      INTEGER := 0;
  _r            RECORD;
  _query        TEXT;
BEGIN
  FOR _r IN SELECT nspname || '.' || relname AS tablename, nspname, relname,
                   attname,
                   TRIM(quote_literal('\"''')
                        FROM SUBSTRING(pg_catalog.pg_get_expr(adbin,adrelid)
                                       FROM '[' || quote_literal('\"''') ||
                                       '].*[' || quote_literal('\"''') ||
                                       ']')) AS seq
            FROM pg_attribute, pg_class,
                 pg_attrdef,   pg_namespace
            WHERE ((attnum > 0)
              AND  (pg_namespace.oid = pg_class.relnamespace)
              AND  (nspname='xtpos')
              AND  (relname !~ '^pkg')
              AND NOT attisdropped
              AND attnotnull
              AND (attrelid = pg_class.oid)
              AND (adrelid = attrelid)
              AND (adnum = attnum)
              AND (pg_catalog.pg_get_expr(adbin, adrelid) ~* 'nextval')
              AND atthasdef) LOOP
    _query := 'SELECT SETVAL(' || quote_literal(_r.seq) ||
                             ', MAX(' || _r.attname || ')) ' ||
              'FROM ' || _r.tablename || ';';
    EXECUTE _query;
    _counter := _counter + 1;
  END LOOP;

  RETURN _counter;
END;
$$ LANGUAGE 'plpgsql';

SELECT fixSerial();
DROP FUNCTION fixSerial();

SELECT deletepackage(pkghead_id)
FROM pkghead
WHERE pkghead_name='retail';
