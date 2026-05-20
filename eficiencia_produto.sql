-- Eficiencia de produção (com tendencia)

-- Calcula a taxa de refugo por produto

WITH CalculoRefugo as (
SELECT pw.ProductID, MONTH(DueDate) as Mes,
SUM(pw.StockedQty) as TotalProd,
SUM(PW.ScrappedQty) as TotalRefugado,
SUM(PW.ScrappedQty)*1.0/SUM(pw.StockedQty)*100 as TaxaRefugo
FROM Production.WorkOrder AS pw
GROUP BY pw.productid, MONTH(DueDate)
)

--Calcula  a Variação do refugo
	SELECT ProductID, Mes, TotalProd, TotalRefugado, TaxaRefugo, 
		(TaxaRefugo - LAG (TaxaRefugo) OVER (PARTITION BY ProductID ORDER BY Mes asc)) as Variacao,

-- Classifica a variação do produto	
	CASE 
		WHEN (TaxaRefugo - LAG (TaxaRefugo) OVER (PARTITION BY ProductID ORDER BY Mes asc)) > 0 THEN 'Piorou'
		WHEN (TaxaRefugo - LAG (TaxaRefugo) OVER (PARTITION BY ProductID ORDER BY Mes asc)) < 0 THEN 'Melhorou'
		ELSE 'Estável'
	END as [Status do Produto]
FROM CalculoRefugo