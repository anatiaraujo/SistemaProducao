--Calcula o tempo de produção
WITH TempoProd as (
	SELECT ProductID, 
	MONTH(StartDate) as Mes,
	AVG(DATEDIFF(DAY, StartDate,EndDate)) as TempoProducao
	FROM Production.workorder
	GROUP BY ProductID, MONTH(StartDate)
),

--Calcula o ranking por mês
Calc_Ranking as (
	SELECT ProductId, Mes, TempoProducao,
	DENSE_RANK () OVER (PARTITION BY Mes ORDER BY TempoProducao asc) as Ranking
	FROM TempoProd
),

Calc_Comparacao as (
	SELECT ProductID, Mes, TempoProducao, Ranking,
	LAG(Ranking) OVER (PARTITION BY ProductID ORDER BY Mes) as RankingAnterior
	FROM Calc_Ranking
)

SELECT ProductID, Mes, Ranking, RankingAnterior,
	CASE 
		WHEN RankingAnterior IS NULL THEN 'Sem Historico'
		WHEN Ranking > RankingAnterior THEN 'Piorou'
		WHEN Ranking < RankingAnterior THEN 'Melhorou'
		ELSE 'Manteve'
		END AS Status
FROM Calc_Comparacao



