/*
	CHECK ON PERIOD
*/
DROP FUNCTION IF EXISTS outcomes_on_period(date,date);
CREATE FUNCTION outcomes_on_period(start_date DATE, end_date date)
RETURNS TABLE(
	period_date DATE,nombre_completo VARCHAR(50),
	monto NUMERIC(10,3), descripcion VARCHAR(50),
	banco_asociado VARCHAR(50), recurrencia VARCHAR(50), fecha_corte DATE)
AS $$
SELECT
	periodo.period_date,
	CONCAT(u.user_name,' ',u.first_name,' ',u.last_name) AS nombre_completo,
	outs_info.amount AS monto,
	UPPER(outs_info.outcome_desc) AS descripcion,
	UPPER(banks.bank_desc) AS banco_asociado,
	UPPER(recs.recurrence_desc) AS recurrencia,
	(make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		pay_info.payment_limit_day
	 	) - pay_info.payment_lapse)::DATE AS fecha_corte
FROM
	users u
	JOIN outcomes outs
	ON u.user_id = outs.user_id
	JOIN outcomes_information outs_info
	ON outs.user_id = outs_info.user_id
	AND outs.outcome_id = outs_info.outcome_id
	JOIN payment_information pay_info
	ON outs.user_id = pay_info.user_id
	AND outs.bank_id = pay_info.bank_id
	AND outs.card_type_id = pay_info.card_type_id
	JOIN (
		SELECT date_trunc('day',d)::date AS period_date
		FROM generate_series($1,$2, INTERVAL '1 DAY') d
	) periodo
	ON periodo.period_date BETWEEN outs_info.start_date AND COALESCE(outs_info.end_date, '9999-01-01'::DATE)
	OR COALESCE(outs_info.end_date, periodo.period_date) BETWEEN
	 ((make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		pay_info.payment_limit_day
	 	) - pay_info.payment_lapse) + 1 - INTERVAL '1 MONTH')::DATE
		AND
	(make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		pay_info.payment_limit_day)  - pay_info.payment_lapse)
	OR periodo.period_date BETWEEN
	((make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		pay_info.payment_limit_day
	 	) - pay_info.payment_lapse) + 1 - INTERVAL '1 MONTH')::DATE
		AND
		(make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		pay_info.payment_limit_day)  - pay_info.payment_lapse)
	JOIN recurrences recs
	ON outs_info.recurrence = recs.recurrence_id
	JOIN bank_information banks
	ON pay_info.bank_id = banks.bank_id
	JOIN card_types cards
	ON pay_info.card_type_id = cards.card_type_id
WHERE
	CASE
	/*cuando el egreso es recurrente y asociado con tarjetas con fechas de cobro definidas*/
	WHEN outs_info.is_periodic = 1 AND pay_info.payment_limit_day IS NOT NULL THEN
		periodo.period_date BETWEEN COALESCE(outs_info.start_date) AND COALESCE(outs_info.end_date, '9999-01-01'::DATE)
		OR (periodo.period_date BETWEEN--valida que este en el mes valido de la TC/TD
	 		((make_date(
			EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
			EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
			pay_info.payment_limit_day
			) - pay_info.payment_lapse) + 1 - INTERVAL '1 MONTH')::DATE
			AND
			(make_date(
			EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
			EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
			pay_info.payment_limit_day
	 		) - pay_info.payment_lapse)
		OR outs_info.end_date BETWEEN -- valida que la fecha fin este dentro del mes de cobro de TC/TD
	 		((make_date(
			EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
			EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
			pay_info.payment_limit_day
	 		) - pay_info.payment_lapse) + 1 - INTERVAL '1 MONTH')::DATE
			AND
			(make_date(
			EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
			EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
			pay_info.payment_limit_day
	 		) - pay_info.payment_lapse)
		 )
	/*cuando el egreso es recurrente y no se asocia con tarjetas  con fechas de cobro definidas*/
	WHEN outs_info.is_periodic = 1 THEN
		periodo.period_date BETWEEN COALESCE(outs_info.start_date) AND COALESCE(outs_info.end_date, '9999-01-01'::DATE)
		OR periodo.period_date BETWEEN COALESCE(outs_info.start_date,outs_info.update_date)
			AND COALESCE(outs_info.end_date, '9999-01-01'::DATE)
	/*cuando no es periodico valida la fecha de pago en el mes siguiente al registro/vigencia*/
	WHEN outs_info.is_periodic = 0 THEN
		periodo.period_date BETWEEN COALESCE(outs_info.start_date,outs_info.update_date)
			AND (COALESCE(outs_info.start_date,outs_info.update_date) + INTERVAL '1 MONTH')::DATE
	ELSE FALSE END
	AND
	CASE
	WHEN recs.recurrence_id = 2 THEN--cobros mensuales
		--pagos a tarjeta
		--COALESCE(pay_info.payment_limit_day - pay_info.payment_lapse,0) = EXTRACT(DAY FROM periodo.period_date)
		COALESCE(pay_info.payment_limit_day,0) = EXTRACT(DAY FROM periodo.period_date)
		OR
		COALESCE(outs_info.payment_day,0) = EXTRACT(DAY FROM periodo.period_date)
	WHEN recs.recurrence_id = 1 THEN-- semanales
		EXTRACT(DAY FROM periodo.period_date) IN (7,14,21)
		OR
		EXTRACT(MONTH FROM periodo.period_date + interval '1 day') <> EXTRACT(MONTH FROM periodo.period_date)
	WHEN recs.recurrence_id = 0 THEN --cobros quincenales
		EXTRACT(DAY FROM periodo.period_date) = 15
		OR
		EXTRACT(MONTH FROM periodo.period_date + interval '1 day') <> EXTRACT(MONTH FROM periodo.period_date)
	WHEN outs_info.is_periodic = 0 THEN
		outs_info.payment_day = EXTRACT(DAY FROM periodo.period_date)
	ELSE FALSE
	END
$$ LANGUAGE SQL;

/* TEST OUTCOMES_ON_PERIOD */
/*
montos y acumulado en el periodo
*/
SELECT
	MES,
	descripcion,
	monto,
	SUM(monto) OVER(PARTITION BY descripcion) AS monto_total
FROM
(
	SELECT
		EXTRACT(MONTH FROM period_date) AS MES, descripcion, SUM(monto) AS monto
	FROM outcomes_on_period('2024-01-01'::DATE, '2024-12-31'::DATE)
	GROUP BY
		EXTRACT(MONTH FROM period_date),
		descripcion
)
ORDER BY
	 MES ASC,descripcion

/*
montos por concepto yFecha de aplicacion
*/
SELECT
	period_date, descripcion, banco_asociado, SUM(monto) monto
FROM outcomes_on_period('2024-05-01'::DATE, '2024-05-30'::DATE)
GROUP BY
	period_date,
	descripcion,
	banco_asociado
ORDER BY period_date;

/*
montos por entidad asociada, concepto y mes
*/
SELECT
	EXTRACT(MONTH FROM period_date) mes,
	banco_asociado,
	descripcion,
	SUM(monto)
FROM outcomes_on_period('2024-01-01'::DATE, '2024-01-31'::DATE)
GROUP BY
	EXTRACT(MONTH FROM period_date),
	descripcion,
	banco_asociado
ORDER BY EXTRACT(MONTH FROM period_date);

/*
montos por entidad asociada y mes
*/
SELECT
	EXTRACT(MONTH FROM period_date) mes,
	banco_asociado,
	--fecha_corte,
	SUM(monto)
FROM outcomes_on_period('2024-01-01'::DATE, '2024-01-31'::DATE)
GROUP BY
	EXTRACT(MONTH FROM period_date),
	--fecha_corte,
	banco_asociado
ORDER BY EXTRACT(MONTH FROM period_date)



/* OUTCOMES ON SPECIFIC DATE */
DROP FUNCTION IF EXISTS outcomes_on_date(DATE);
CREATE FUNCTION outcomes_on_date(sample_date DATE)
RETURNS TABLE(
	period_date DATE,nombre_completo VARCHAR(50),
	monto NUMERIC(10,3), descripcion VARCHAR(50),
	banco_asociado VARCHAR(50), recurrencia VARCHAR(50), fecha_corte DATE)
AS $$
SELECT
	period_date,
	nombre_completo,
	monto,
	descripcion,
	banco_asociado,
	recurrencia,
	fecha_corte
FROM outcomes_on_period($1, $1)
$$ LANGUAGE SQL;

SELECT * FROM outcomes_on_date('2024-02-10')

SELECT * FROM OUTCOMES_INFORMATION WHERE BANK_ID = 1 AND CARD_TYPE_ID = 1
