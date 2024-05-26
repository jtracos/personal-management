--SELECT * FROM dim_outcomes;
DROP FUNCTION IF EXISTS calc_outcomes_on_period(date, date);
CREATE FUNCTION calc_outcomes_on_period(date1 date, date2 date)
RETURNS 
TABLE (
	period_date DATE, user_id INTEGER, outcome_id INTEGER, 
	descripcion VARCHAR(50), dia_pago INTEGER, entidad_asociada VARCHAR(50),
	recurrencia VARCHAR(50), fecha_corte DATE, fecha_limite_pago DATE,
	monto NUMERIC(10,3))
AS
$$
SELECT
	periodo.period_date,
	outs.user_id,
	outs.outcome_id,
	UPPER(outs.descripcion) descripcion,
	outs.fecha_pago as dia_pago,
	outs.entidad_asociada,
	outs.recurrencia,
	(make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		outs.fecha_pago
	 	) - outs.periodo_pago)::DATE AS fecha_corte,
	make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		outs.fecha_pago) AS fecha_limite_pago,
	outs.monto
FROM
	dim_outcomes outs
	JOIN (
		SELECT date_trunc('day',d)::date AS period_date
		FROM generate_series($1, $2, INTERVAL '1 DAY') d
	) periodo
	-- cuando es vigente el egreso
	ON periodo.period_date BETWEEN outs.fecha_inicio AND COALESCE(outs.fecha_fin, '9999-01-01'::DATE)
	OR
	-- cuando la fecha fin esta dentro del corte
	outs.fecha_fin BETWEEN
	((make_date(
				EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
				EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
				outs.fecha_pago) - outs.periodo_pago)
				+ 1 - INTERVAL '1 MONTH')::DATE
	AND (make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		outs.fecha_pago
	 	) - outs.periodo_pago)::DATE
	-- cuando la fecha fin se encuentra en el periodo de registro siguiente
	OR outs.fecha_fin  BETWEEN (make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		outs.fecha_pago
	 	) +1 - outs.periodo_pago)::DATE
		AND
		((make_date(
				EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
				EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
				outs.fecha_pago) - outs.periodo_pago)
				- 1 + INTERVAL '1 MONTH')::DATE
WHERE
	CASE
	WHEN outs.recurrencia = 'MONTHLY' THEN
		--pagos a tarjeta
		--COALESCE(outs.fecha_pago - outs.periodo_pago,0) = EXTRACT(DAY FROM periodo.period_date)
		COALESCE(outs.fecha_pago,0) = EXTRACT(DAY FROM periodo.period_date)
		AND CASE WHEN outs.tipo_tarjeta = 'CREDITO' THEN
			outs.fecha_inicio NOT BETWEEN (make_date(
				EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
				EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
				outs.fecha_pago
	 		) +1 - outs.periodo_pago)::DATE
			AND
			((make_date(
				EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
				EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
				outs.fecha_pago) - outs.periodo_pago)
				- 1 + INTERVAL '1 MONTH')::DATE
		ELSE TRUE END

	WHEN outs.recurrencia = 'WEEKLY' THEN-- semanales
		EXTRACT(DAY FROM periodo.period_date) IN (7,14,21)
		OR
		EXTRACT(MONTH FROM periodo.period_date + interval '1 day') <> EXTRACT(MONTH FROM periodo.period_date)
	WHEN outs.recurrencia = 'BIWEEKLY' THEN --cobros quincenales
		EXTRACT(DAY FROM periodo.period_date) = 15
		OR
		EXTRACT(MONTH FROM periodo.period_date + interval '1 day') <> EXTRACT(MONTH FROM periodo.period_date)
	WHEN outs.is_periodic = 0 THEN
		periodo.period_date BETWEEN outs.fecha_inicio AND (outs.fecha_inicio + INTERVAL '1 MONTH')::DATE
		AND outs.fecha_pago = EXTRACT(DAY FROM periodo.period_date)
	ELSE FALSE
	END
ORDER BY periodo.period_date ASC;
$$ LANGUAGE SQL;

SELECT * FROM dim_outcomes;

DROP FUNCTION IF EXISTS calc_outcomes_on_date(date);
CREATE FUNCTION calc_outcomes_on_date(date1 date)
RETURNS 
TABLE (
	period_date DATE, user_id INTEGER, outcome_id INTEGER, 
	descripcion VARCHAR(50), dia_pago INTEGER, entidad_asociada VARCHAR(50),
	recurrencia VARCHAR(50), fecha_corte DATE, fecha_limite_pago DATE,
	monto NUMERIC(10,3))
AS
$$
SELECT
	period_date, user_id, outcome_id, descripcion,
	dia_pago, entidad_asociada, recurrencia,
	fecha_corte, fecha_limite_pago, monto
FROM calc_outcomes_on_period($1, $1);
$$ LANGUAGE SQL;

/*
SELECT * FROM OUTCOMES_INFORMATION;
SELECT * FROM OUTCOMES;
SELECT * FROM PAYMENT_INFORMATION;
SELECT * FROM CARD_TYPES;
SELECT * FROM RECURRENCES;
*/
