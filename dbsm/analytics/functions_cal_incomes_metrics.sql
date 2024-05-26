--SELECT * FROM dim_incomes;
DROP FUNCTION IF EXISTS calc_incomes_on_period(date, date);
CREATE FUNCTION calc_incomes_on_period(date1 date, date2 date)
RETURNS 
TABLE (
	period_date DATE, user_id INTEGER, income_id INTEGER, 
	descripcion VARCHAR(50), dia_pago INTEGER,
	entidad_asociada VARCHAR(50), recurrencia VARCHAR(50),
	fecha_limite_pago DATE, monto NUMERIC(10,3))
AS
$$
SELECT
	periodo.period_date,
	ins.user_id,
	ins.income_id,
	UPPER(ins.descripcion) descripcion,
	ins.fecha_pago as dia_pago,
	ins.entidad_asociada,
	ins.recurrencia,
	make_date(
		EXTRACT(YEAR FROM periodo.period_date)::INTEGER,
		EXTRACT(MONTH FROM periodo.period_date)::INTEGER,
		ins.fecha_pago) AS fecha_limite_pago,
	ins.monto
FROM
	dim_incomes ins
	JOIN (
		SELECT date_trunc('day',d)::date AS period_date
		FROM generate_series($1, $2, INTERVAL '1 DAY') d
	) periodo
	-- cuando es vigente el ingreso
	ON periodo.period_date BETWEEN ins.fecha_inicio AND COALESCE(ins.fecha_fin, '9999-01-01'::DATE)
WHERE
	CASE
	WHEN ins.recurrencia = 'MONTHLY' THEN
		--pagos a tarjeta
		COALESCE(ins.fecha_pago,0) = EXTRACT(DAY FROM periodo.period_date)
	WHEN ins.recurrencia = 'WEEKLY' THEN-- semanales
		EXTRACT(DAY FROM periodo.period_date) IN (7,14,21)
		OR
		EXTRACT(MONTH FROM periodo.period_date + interval '1 day') <> EXTRACT(MONTH FROM periodo.period_date)
	WHEN ins.recurrencia = 'BIWEEKLY' THEN --cobros quincenales
		EXTRACT(DAY FROM periodo.period_date) = 15
		OR
		EXTRACT(MONTH FROM periodo.period_date + interval '1 day') <> EXTRACT(MONTH FROM periodo.period_date)
	WHEN ins.is_periodic = 0 THEN
		periodo.period_date BETWEEN ins.fecha_inicio AND (ins.fecha_inicio + INTERVAL '1 MONTH')::DATE
		AND ins.fecha_pago = EXTRACT(DAY FROM periodo.period_date)
	ELSE FALSE
	END
ORDER BY periodo.period_date ASC;
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS calc_incomes_on_date(date);
CREATE FUNCTION calc_incomes_on_date(date1 date)
RETURNS 
TABLE (
	period_date DATE, user_id INTEGER, income_id INTEGER, 
	descripcion VARCHAR(50), dia_pago INTEGER,
	entidad_asociada VARCHAR(50), recurrencia VARCHAR(50),
	fecha_limite_pago DATE, monto NUMERIC(10,3))
AS
$$
SELECT
	period_date, user_id, income_id, 
	descripcion, dia_pago,
	entidad_asociada, recurrencia,
	fecha_limite_pago, monto
FROM calc_incomes_on_period($1, $1);
$$ LANGUAGE SQL;

