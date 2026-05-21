-- Ranking dos 3 produtos que mais pioraram por mês


--Calcula a taxa de refugo
WITH CalculoRefugo as (
SELECT pw.ProductID, MONTH(DueDate) as Mes,
SUM(pw.StockedQty) as TotalProd,
SUM(PW.ScrappedQty) as TotalRefugado,
SUM(PW.ScrappedQty)*1.0/SUM(pw.StockedQty)*100 as TaxaRefugoAtual
FROM Production.WorkOrder AS pw
GROUP BY pw.productid, MONTH(DueDate)
),

--Calcula a taxa anterior
CalcTaxaAnterior as (
SELECT ProductID, Mes, TotalProd, TotalRefugado, TaxaRefugoAtual,
	LAG (TaxaRefugoAtual) OVER (PARTITION BY ProductID ORDER BY Mes asc) as TaxaRefugoAnterior
FROM CalculoRefugo
),

--Calcula a variação
CalcVariacao as (
SELECT ProductID, Mes, TotalProd, TotalRefugado, TaxaRefugoAtual,TaxaRefugoAnterior,
(TaxaRefugoAtual - TaxaRefugoAnterior) as Variacao
FROM CalcTaxaAnterior
)

--Classifica a variação
SELECT *
FROM (SELECT ProductID, Mes, TotalProd, TotalRefugado, TaxaRefugoAtual,TaxaRefugoAnterior,
	CASE
		WHEN Variacao is Null THEN 'Sem Historico'
		WHEN Variacao > 0 THEN 'Piorou'
		WHEN Variacao < 0 THEN 'Melhorou'
		ELSE 'Estavel'
		END AS Status,
	ROW_NUMBER () OVER (PARTITION BY Mes ORDER BY Variacao desc) as Ranking 
FROM CalcVariacao) AS T
WHERE Status = 'Piorou' AND Ranking <= 3


