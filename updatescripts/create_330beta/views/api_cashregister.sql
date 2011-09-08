
-- Cash Register
SELECT dropIfExists('VIEW', 'api_cashregister', 'xtpos');
CREATE VIEW xtpos.api_cashregister
AS
   SELECT 
     warehous_code AS site,
     terminal_number AS terminal,
     CASE 
       WHEN (reghist_id IS NULL) THEN false
       ELSE true
     END AS active,
     formatdatetime(reghist_open_time) AS opened,
     COALESCE(opn.regdetail_endbal,0) AS opening_balance,
     COALESCE(CASE 
       WHEN (reghist_id IS NULL) THEN 
         (SELECT regdetail_endbal
          FROM xtpos.regdetail
            JOIN xtpos.reghist ON (reghist_id=regdetail_reghist_id)
          WHERE (reghist_terminal_id=rtlsiteterm_terminal_id)
          ORDER BY regdetail_time DESC
          LIMIT 1)
       ELSE
         COALESCE(opn.regdetail_endbal,0) + 
         COALESCE(SUM(adj.regdetail_transferamt + adj.regdetail_adjustamt),0) +
         xtpos.reghistSales(reghist_id,'S') 
     END,0) AS current_balance,
     xtpos.reghistSales(reghist_id) AS total_sales,
     xtpos.reghistSales(reghist_id,'S') AS cash_sales,
     xtpos.reghistSales(reghist_id,'C') AS credit_card_sales,  
     xtpos.reghistSales(reghist_id,'K') AS check_sales
   FROM xtpos.rtlsiteterm
     JOIN xtpos.rtlsite ON (rtlsite_id=rtlsiteterm_rtlsite_id)
     JOIN xtpos.terminal ON (terminal_id=rtlsiteterm_terminal_id)
     JOIN site() ON (warehous_id=rtlsite_warehous_id)
     LEFT OUTER JOIN xtpos.reghist ON ((reghist_terminal_id=terminal_id)
		                   AND (reghist_open))
     LEFT OUTER JOIN xtpos.regdetail opn ON ((opn.regdetail_reghist_id=reghist_id)
			                  AND (opn.regdetail_type='O'))
     LEFT OUTER JOIN xtpos.regdetail adj ON ((adj.regdetail_reghist_id=reghist_id)
			                  AND (adj.regdetail_type='A'))
   WHERE (warehous_active)
   GROUP BY warehous_code, terminal_number, reghist_id, reghist_open_time, 
     opn.regdetail_startbal, opn.regdetail_endbal, rtlsiteterm_terminal_id
   ORDER BY warehous_code, terminal_number;

GRANT ALL ON TABLE xtpos.api_cashregister TO xtrole;
COMMENT ON VIEW xtpos.api_cashregister IS 'Cash Register';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO xtpos.api_cashregister DO INSTEAD

  NOTHING;

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO xtpos.api_cashregister DO INSTEAD

  NOTHING;
    
CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO xtpos.api_cashregister DO INSTEAD

  NOTHING;
  

