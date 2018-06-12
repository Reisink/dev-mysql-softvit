SELECT 
 MONTH(REFERENCIA) AS MES,
 SUM(CASE WHEN YEAR(REFERENCIA) = 2017 THEN FATURAMENTO ELSE 0 END) AS ANO_2017,
 SUM(CASE WHEN YEAR(REFERENCIA) = 2018 THEN FATURAMENTO ELSE 0 END) AS ANO_2018,
 ROUND(
  100 * (SUM(CASE WHEN YEAR(REFERENCIA) = 2018 THEN FATURAMENTO ELSE 0 END) / SUM(CASE WHEN YEAR(REFERENCIA) = 2017 THEN FATURAMENTO ELSE 0 END) - 1)
 ,2) AS CRESCIMENTO 

 
FROM TLogFaturamentoMensal
GROUP BY MONTH(REFERENCIA)