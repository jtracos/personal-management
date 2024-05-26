DROP VIEW IF EXISTS dim_outcomes;
CREATE OR REPLACE VIEW dim_outcomes
AS
SELECT
	outs.user_id,
	outs.outcome_id,
	UPPER(outs_info.outcome_desc) as descripcion,
	outs_info.start_time as fecha_inicio,
	outs_info.end_time as fecha_fin,
	outs_info.is_periodic,
	CASE
	WHEN outs_info.payment_day IS NOT NULL THEN outs_info.payment_day
	WHEN pay_info.payment_limit_day IS NOT NULL THEN pay_info.payment_limit_day
	END AS fecha_pago,
	pay_info.payment_lapse periodo_pago ,
	recs.recurrence_desc as recurrencia,
	banks.bank_desc as entidad_asociada,
	cards.card_type_desc tipo_tarjeta,
	outs_info.amount as monto
	
FROM
	OUTCOMES outs
	JOIN (
		SELECT
			user_id,
			outcome_id,
			recurrence,
			amount,
			update_date,
			start_date,
			end_date,
			payment_day,
			is_periodic,
			outcome_desc,
			CASE WHEN DENSE_RANK() OVER (
				partition by user_id, outcome_id order by update_date ASC) = 1
			THEN start_date
			ELSE update_date
			END start_time,
			COALESCE((
				LAG(update_date) OVER (
				partition by user_id, outcome_id 
				order by update_date DESC) - INTERVAL '1 DAY')::DATE,
				end_date) end_time
		FROM OUTCOMES_INFORMATION
		 ) outs_info
	ON outs.outcome_id = outs_info.outcome_id
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