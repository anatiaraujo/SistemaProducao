--Quais clientes mais estão atrasando e gerando maior impacto financeiro

WITH Calc_Impacto as (
	SELECT CustomerID, 
		MONTH(OrderDate) as Mes,
		AVG(DATEDIFF(DAY,DueDate,ShipDate)) as Media_Entrega,
		SUM(TotalDue) as Impacto_Financeiro
	FROM Sales.SalesOrderHeader
	GROUP BY CustomerID, MONTH(OrderDate)
),

Calculo_Ranks as (
	SELECT CustomerID, Mes, Media_Entrega, Impacto_Financeiro,
		DENSE_RANK () OVER (PARTITION BY Mes ORDER BY Media_Entrega desc) as Rank_atraso,
		DENSE_RANK () OVER (PARTITION BY Mes ORDER BY Impacto_Financeiro desc) as Rank_Valor
	FROM Calc_Impacto
)

SELECT Rank_Atraso + Rank_Valor as Score, CustomerID, Mes, Media_Entrega, Impacto_Financeiro
FROM Calculo_Ranks
ORDER BY Score asc
