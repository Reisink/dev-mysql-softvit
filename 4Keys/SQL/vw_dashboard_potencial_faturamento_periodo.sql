SELECT 
 DATE_SUB(DATE(data_inclusao), INTERVAL DAY(data_inclusao) - 1 DAY) AS PERIODO,
 SUM(CASE WHEN CLASSIFICACAO = 'A' THEN 1 ELSE 0 END) AS CLASSE_A,
 SUM(CASE WHEN CLASSIFICACAO = 'B' THEN 1 ELSE 0 END) AS CLASSE_B,
 SUM(CASE WHEN CLASSIFICACAO = 'C' THEN 1 ELSE 0 END) AS CLASSE_C,
 SUM(CASE WHEN CLASSIFICACAO = 'D' THEN 1 ELSE 0 END) AS CLASSE_D,
 SUM(CASE WHEN CLASSIFICACAO = 'NI' THEN 1 ELSE 0 END) AS CLASSE_NI,
 SUM(CASE WHEN CLASSIFICACAO = 'ND' THEN 1 ELSE 0 END) AS CLASSE_ND,
 COUNT(1) AS TOTAL,
 ROUND(SUM(CASE WHEN CLASSIFICACAO = 'D' THEN 1 ELSE 0 END) / (COUNT(1) - SUM(CASE WHEN CLASSIFICACAO = 'NI' THEN 1 ELSE 0 END)), 4) AS FAT_MENOR_3K

FROM Tbase_relatorio_clt
WHERE YEAR(data_inclusao) = YEAR(CURDATE()) AND STATUS_CLIENTE = 'ATIVO'
GROUP BY MONTH(data_inclusao)
