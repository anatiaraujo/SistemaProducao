--Qual produto tem a pior taxa de refugo dentro de cada mês

--Calcular Rank de Perda
WITH CalculoRank as (
SELECT pw.ProductId, MONTH(pw.DueDate) AS Mes, 
SUM(pw.ScrappedQty) as [TotalRefugado],
SUM(pw.StockedQty) as [TotalProduzido],
(SUM(pw.ScrappedQty) *1.0/SUM(pw.StockedQty))*100 as [Taxa de Perda],
ROW_NUMBER () OVER (PARTITION BY MONTH(pw.DueDate) ORDER BY (SUM(pw.ScrappedQty) *1.0/SUM(pw.StockedQty))*100 DESC) AS [Rank de Perda]
FROM Production.WorkOrder AS pw
INNER JOIN Production.Product as pp on pp.ProductID = pw.ProductID
GROUP BY MONTH(DueDate), pw.ProductID
)

--Filtrar TOP 1
	SELECT *
	FROM CalculoRank
	WHERE [Rank de Perda] = 1


