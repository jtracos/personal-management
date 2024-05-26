SELECT * FROM incomes_information;
SELECT * FROM BANK_INFORMATION
SELECT * FROM dim_outcomes;
SELECT * FROM dim_incomes;
SELECT * FROM OUTCOMES_INFORMATION;
-- detalle egresos esperados 2024
SELECT
	EXTRACT(YEAR FROM period_date + 1) as anio,
	EXTRACT(MONTH FROM period_date + 1) as num_mes,
	month_esp(period_date+1) AS mes_quincena_desc,
	CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
	THEN 1
	WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
	ELSE 2 END AS quincena,
	period_date,
	descripcion,
	entidad_asociada as banco_asociado,
	monto
FROM calc_outcomes_on_period('2024-01-01', '2024-12-31');

-- detalle esperado 2024
SELECT
	EXTRACT(YEAR FROM period_date + 1) as anio,
	EXTRACT(MONTH FROM period_date + 1) as num_mes,
	month_esp(period_date+1) AS mes_quincena_desc,
	CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
	THEN 1
	WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
	ELSE 2 END AS quincena,
	period_date,
	descripcion,
	entidad_asociada as banco_asociado,
	monto
FROM calc_incomes_on_period('2023-12-30', '2024-12-31')
ORDER BY period_date ASC;

/*
detalle de gastos quincenales estimadas
*/
SELECT
	EXTRACT(YEAR FROM period_date + 1) as anio,
	EXTRACT(MONTH FROM period_date + 1) as num_mes,
	month_esp(period_date+1) AS mes_quincena_desc,
	CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
	THEN 1
	WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
	ELSE 2 END AS quincena,
	descripcion,
	entidad_asociada as banco_asociado,
	period_date,
	monto as gastos
FROM calc_outcomes_on_period('2024-01-01', '2025-12-31')


/*
agrupacion de movimientos por quincena efectiva
*/
SELECT
	anio,
	num_mes,
	mes_quincena_desc,
	quincena,
	gastos,
	ingresos,
	ingresos - gastos  AS disponible
FROM
	(
		SELECT
			EXTRACT(YEAR FROM period_date + 1) as anio,
			EXTRACT(MONTH FROM period_date + 1) as num_mes,
			month_esp(period_date+1) AS mes_quincena_desc,
			CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
			THEN 1
			WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
			ELSE 2 END AS quincena,
			SUM(monto) as gastos
		FROM calc_outcomes_on_period('2024-01-01', '2025-12-31')
		GROUP BY
			EXTRACT(YEAR FROM period_date + 1),
			EXTRACT(MONTH FROM period_date + 1),
			month_esp(period_date+1),
			CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
			THEN 1
			WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
			ELSE 2 END
	) outs
	JOIN
	(
		SELECT
			EXTRACT(YEAR FROM period_date + 1) as anio,
			EXTRACT(MONTH FROM period_date + 1) as num_mes,
			month_esp(period_date+1) AS mes_quincena_desc,
			CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
			THEN 1
			WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
			ELSE 2 END AS quincena,
			SUM(monto) as ingresos
		FROM calc_incomes_on_period('2023-01-01', '2025-12-31')
		GROUP BY
				EXTRACT(YEAR FROM period_date + 1),
				month_esp(period_date+1),
				EXTRACT(MONTH FROM period_date + 1),
				CASE WHEN EXTRACT(MONTH FROM period_date) <> EXTRACT(MONTH FROM period_date + 1)
				THEN 1
				WHEN EXTRACT(DAY FROM period_date) < 15 THEN 1
				ELSE 2 END
	) ins
	USING(mes_quincena_desc,quincena,num_mes,anio)
ORDER BY anio ASC, num_mes ASC, quincena ASC








	