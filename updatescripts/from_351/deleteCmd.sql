UPDATE pkghead SET pkghead_indev = true WHERE pkghead_name = 'xtpos';

DELETE FROM xtpos.pkgcmdarg
WHERE cmdarg_cmd_id IN (
  SELECT cmd_id
  FROM xtpos.pkgcmd
  WHERE (cmd_title IN ('Retail Site','Retail Sites')));

DELETE FROM xtpos.pkgcmd
WHERE (cmd_title IN ('Retail Site','Retail Sites'));

UPDATE pkghead SET pkghead_indev = false WHERE pkghead_name = 'xtpos';
