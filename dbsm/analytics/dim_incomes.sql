DROP VIEW IF EXISTS dim_incomes;
CREATE OR REPLACE VIEW dim_incomes
AS
SELECT
	outs.user_id,
	outs.income_id,
	outs_info.income_desc as descripcion,
	outs_info.start_date as fecha_inicio,
	outs_info.end_date as fecha_fin,
	outs_info.is_periodic,
	pay_info.payment_limit_day as fecha_pago,
	recs.recurrence_desc as recurrencia,
	banks.bank_desc as entidad_asociada,
	cards.card_type_desc tipo_tarjeta,
	outs_info.amount as monto
FROM
	INCOMES outs
	JOIN (
		SELECT
			user_id,
			income_id,
			recurrence,
			amount,
			is_periodic,
			income_desc,
			update_date as start_date,
			(
				LAG(update_date) OVER (
				partition by user_id, income_id 
				order by update_date DESC) - INTERVAL '1 DAY')::DATE end_date
		FROM INCOMES_INFORMATION
		 ) outs_info
	ON outs.income_id = outs_info.income_id
	AND outs.user_id = outs_info.user_id
	LEFT JOIN PAYMENT_INFORMATION pay_info
	ON outs.user_id = pay_info.user_id
	AND outs.bank_id = pay_info.bank_id
	AND outs.card_type_id = pay_info.card_type_id
	LEFT JOIN RECURRENCES recs
	ON outs_info.recurrence = recs.recurrence_id
	LEFT JOIN BANK_INFORMATION banks
	ON pay_info.bank_id = banks.bank_id
	LEFT JOIN CARD_TYPES cards
	ON pay_info.card_type_id = cards.card_type_id
;