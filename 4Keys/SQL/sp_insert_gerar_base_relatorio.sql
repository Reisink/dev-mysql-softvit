CREATE DEFINER=`softvit1`@`172.16.0.8` PROCEDURE `sp_insert_gerar_base_relatorio`()
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'Procedure para consolidar e alimentar a tabela base para geração dos relatórios e dashboards'
BEGIN

# Rhemerson Reis em 09/05/2018

TRUNCATE Tbase_relatorio_clt;

INSERT INTO Tbase_relatorio_clt

SELECT
	clt.NUM_PROPOSTA,
	clt.MERCHANT_ID,
	clt.CNPJ,
	clt.NOME_FANTASIA,
	clt.ESTADO,
	clt.CIDADE,
	clt.WORKFLOW_ADQUIRENTE,
	clt.STATUS_CLIENTE,
	clt.VENDEDOR,
	clt.ULTIMO_FATURAMENTO,
	clt.FAT_TOTAL_MES_ATUAL,
	clt.POTENCIAL,
	clt.DATA_INCLUSAO,
	clt.DATA_ENVIO_PROPOSTA,
	clt.DATA_AFILIACAO,
	clt.DATA_INSTALACAO,
	clt.DATA_ATIVACAO,
	cne.CNAE,
	cne.SEGMENTO,
	-- (select max(faturamento) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND referencia > date_sub(curdate(), interval 365 day)) as POTENCIAL_FAT,
	(select max(faturamento) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID) as POTENCIAL_FAT,
	(select sum(faturamento) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID) as FATURAMENTO_TOTAL,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = last_day(curdate())) as M0,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 1 month)) as M1,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 2 month)) as M2,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 3 month)) as M3,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 12 month)) as M0Y1,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 13 month)) as M1Y1,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 14 month)) as M2Y1,
	(select faturamento from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND last_day(referencia) = date_sub(last_day(curdate()), interval 15 month)) as M3Y1,
	(select sum(faturamento) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND referencia > date_sub(curdate(), interval 365 day)) as ULTIMOS_12M,
	(select round(avg(faturamento),2) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND referencia > date_sub(curdate(), interval 365 day)) as MEDIO_ULTIMOS_12M,
	(select sum(faturamento) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND (year(curdate()) - 1) = year(referencia)) as Y1,
	(select round(avg(faturamento),2) from TLogFaturamentoMensal fat where fat.MERCHANT_ID = clt.MERCHANT_ID AND (year(curdate()) - 1) = year(referencia)) as MEDIO_Y1,
	NULL AS CLASSIFICACAO

FROM Tcliente clt
JOIN Tcnae cne ON clt.CNAE = cne.CNAE
ORDER BY NUM_PROPOSTA DESC;


UPDATE Tbase_relatorio_clt clt 
	SET CLASSIFICACAO = 	CASE 	
									WHEN (COALESCE(POTENCIAL_FAT,0) = 0) THEN 'NI'
									WHEN POTENCIAL_FAT <  3000 THEN 'D'
									WHEN POTENCIAL_FAT <= 12000 THEN 'C'
									WHEN POTENCIAL_FAT <= 30000 THEN 'B'
									WHEN POTENCIAL_FAT >  30000 THEN 'A'
									ELSE 'ND'
								END;


END