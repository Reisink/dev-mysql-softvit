SELECT 
 referencia,
 segmento, 
 COUNT(1) AS clientes,
 SUM(faturamento) AS faturamento,
 ROUND(AVG(faturamento), 2) AS ticket_medio,
 MAX(faturamento) AS bechmark,
 MIN(faturamento) AS minimo
FROM TLogFaturamentoMensal fat
JOIN Tbase_relatorio_clt clt ON clt.MERCHANT_ID = fat.MERCHANT_ID
GROUP BY referencia, segmento
ORDER BY referencia DESC, SUM(faturamento) DESC