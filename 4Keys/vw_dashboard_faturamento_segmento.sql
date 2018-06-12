SELECT 
 referencia,
 segmento, 
 SUM(faturamento) AS faturamento
FROM TLogFaturamentoMensal fat
JOIN Tbase_relatorio_clt clt ON clt.MERCHANT_ID = fat.MERCHANT_ID
GROUP BY referencia, segmento
ORDER BY referencia DESC, SUM(faturamento) DESC