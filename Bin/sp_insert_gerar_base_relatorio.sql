CREATE DEFINER=`softvit1`@`172.16.0.8` PROCEDURE `sp_insert_gerar_base_relatorio`()
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN

# Rhemerson Reis em 07/06/2018

TRUNCATE TLogFaturamentoMensal;
INSERT INTO TLogFaturamentoMensal
SELECT cnpj, DATE(DATE_FORMAT(DATA, '%Y-%m-01')) AS referencia, ROUND(SUM(faturamento),2) AS faturamento
FROM TlogFaturamento lg
GROUP BY cnpj, DATE_FORMAT(DATA, '%Y-%m-01');


TRUNCATE TbaseRelatorioClt;
INSERT INTO TbaseRelatorioClt

SELECT
	clt.NUM_PROPOSTA,
	clt.MERCHANT_ID,
	clt.CNPJ,
	clt.NOME_FANTASIA,
	clt.STATUS_CLIENTE,
	clt.ESTADO,
	clt.CIDADE,
	clt.VENDEDOR,
	clt.ULTIMO_FATURAMENTO,
	clt.DATA_INCLUSAO,
	cne.CNAE,
	cne.SEGMENTO,
	(select count(1) from Tcliente c where left(c.cnpj, 8) = left(clt.cnpj, 8)) as qtd_franquias,
	(select desc_status from TstatusProposta id where idstatus = clt.STATUS_PROPOSTA) as STATUS_PROPOSTA,
	-- (select max(faturamento) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND referencia > date_sub(curdate(), interval 365 day)) as POTENCIAL_FAT,
	(select max(faturamento) from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ) as POTENCIAL_FAT,
	(select sum(faturamento) from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ) as FATURAMENTO_TOTAL,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = last_day(curdate())) as M0,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 1 month)) as M1,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 2 month)) as M2,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 3 month)) as M3,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 12 month)) as M0Y1,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 13 month)) as M1Y1,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 14 month)) as M2Y1,
	(select faturamento from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND last_day(referencia) = date_sub(last_day(curdate()), interval 15 month)) as M3Y1,
	(select sum(faturamento) from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND referencia > date_sub(curdate(), interval 365 day)) as ULTIMOS_12M,
	(select round(avg(faturamento),2) from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND referencia > date_sub(curdate(), interval 365 day)) as MEDIO_ULTIMOS_12M,
	(select sum(faturamento) from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND (year(curdate()) - 1) = year(referencia)) as Y1,
	(select round(avg(faturamento),2) from TLogFaturamentoMensal fat where fat.CNPJ = clt.CNPJ AND (year(curdate()) - 1) = year(referencia)) as MEDIO_Y1,
	NULL AS CLASSIFICACAO,
	NULL AS FAROL_FATURAMENTO

FROM Tcliente clt
JOIN Tcnae cne ON clt.CNAE = cne.CNAE
GROUP BY clt.CNPJ
ORDER BY NUM_PROPOSTA DESC;


UPDATE TbaseRelatorioClt clt 
	SET CLASSIFICACAO = 	CASE 	
									WHEN (COALESCE(POTENCIAL_FAT,0) = 0) THEN 'SEM FATURAMENTO'
									WHEN POTENCIAL_FAT <= 11000 THEN 'BÁSICO'
									WHEN POTENCIAL_FAT <= 60000 THEN 'GOLD'
									WHEN POTENCIAL_FAT >  60000 THEN 'PREMIER'
									ELSE 'ND'
								END;
								
UPDATE TbaseRelatorioClt clt 
	SET FAROL_FATURAMENTO = CASE 	
										WHEN IFNULL(FATURAMENTO_TOTAL, 0) = 0 THEN 'NUNCA FATUROU'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) < 30 THEN 'FATURANDO'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) BETWEEN 30 AND 60 THEN '+30 DIAS S/ FAT'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) BETWEEN 60 AND 90 THEN '+60 DIAS S/ FAT'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) BETWEEN 90 AND 120 THEN '+90 DIAS S/ FAT'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) BETWEEN 120 AND 180 THEN '+120 DIAS S/ FAT'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) BETWEEN 180 AND 365 THEN '+6 MESES S/ FAT'
										WHEN DATEDIFF(CURDATE(), ULTIMO_FATURAMENTO) > 365 THEN '+1 ANO S/ FAT'
										ELSE 'ND'
									END;							



END