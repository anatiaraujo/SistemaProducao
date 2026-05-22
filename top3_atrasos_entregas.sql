--Quais os clientes com maior atraso nas entregas

--Calcula tempo de entrega
WITH Calc_TempoEntrega as (
SELECT CustomerID, 
	MONTH(OrderDate) as Mes,
	AVG(DATEDIFF(DAY, OrderDate, ShipDate)) AS TempoEntrega
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, MONTH(OrderDate)
),

--Calcula Ranking de entrega
Calculo_Rank as (
SELECT CustomerID, Mes, TempoEntrega,
	DENSE_RANK () OVER (PARTITION BY Mes ORDER BY TempoEntrega DESC) AS Ranking
FROM Calc_TempoEntrega
)

--Seleciona os tres piores tempos de entrega
SELECT CustomerID, Mes, TempoEntrega, Ranking
FROM Calculo_Rank
WHERE Ranking <= 3