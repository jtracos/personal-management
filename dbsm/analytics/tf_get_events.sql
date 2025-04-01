--tf de prueba con denormalizacion
CREATE OR REPLACE FUNCTION stg.tf_get_events_with_labels( user_ integer)
RETURNS 
TABLE (
  descripcion varchar(50),
  recurrencia varchar(50),
  fecha_inicio_programada DATE,
  fecha_fin_programada DATE,
  tipo varchar(50),
  dia_pago INTEGER,
  payment_limit_day INTEGER,
  payment_lapse INTEGER,
  banco_asociado varchar(50),
  tipo_tarjeta_asoc varchar(50),
  ind_ult_actualizacion INTEGER
  )
AS
$$
  SELECT
    UPPER(EI.event_desc) AS descripcion,
    R.recurrence_desc AS recurrencia,
    CASE WHEN EI.start_date IS NULL THEN EI.signup_date ELSE EI.signup_date END AS fecha_inicio_programada,
    EI.end_date AS fecha_fin_programada,
    ET.event_desc AS tipo,
    EI.payment_day as dia_pago,
    PI.payment_limit_day,
    PI.payment_lapse,
    BI.bank_desc AS banco_asociado,
    CT.card_type_desc AS tipo_tarjeta_asoc,
    EI.ind_active AS ind_activo
  FROM stg.EVENT_INFORMATION EI
    LEFT JOIN stg.EVENT_TYPE ET
    ON EI.EVENT_TYPE = ET.ID
    LEFT JOIN stg.PAYMENT_INFORMATION PI
    ON EI.PAYMENT_ID = PI.PAYMENT_ID
    LEFT JOIN stg.BANK_INFORMATION BI
    ON PI.BANK_ID = BI.BANK_ID
    LEFT JOIN stg.CARD_TYPES CT
    ON PI.CARD_TYPE_ID = CT.CARD_TYPE_ID
    LEFT JOIN stg.RECURRENCES R
    ON EI.RECURRENCE = R.RECURRENCE_ID
  WHERE EI.USER_ID = user_
$$ LANGUAGE SQL;
-- tf de prueba de actualizaciones denormalizada
CREATE OR REPLACE FUNCTION stg.tf_get_events_updates_with_labels( user_ integer)
RETURNS 
TABLE (
  descripcion varchar(50),
  recurrencia varchar(50),
  fecha_inicio_programada DATE,
  fecha_fin_programada DATE,
  fecha_actualizacion_monto DATE,
  monto NUMERIC(10,3),
  tipo varchar(50),
  dia_pago INTEGER,
  payment_limit_day INTEGER,
  payment_lapse INTEGER,
  banco_asociado varchar(50),
  tipo_tarjeta_asoc varchar(50),
  ind_activo INTEGER
  )
AS
$$
  SELECT
    UPPER(EI.event_desc) AS descripcion,
    R.recurrence_desc AS recurrencia,
    CASE WHEN EI.start_date IS NULL THEN EI.signup_date ELSE EI.signup_date END AS fecha_inicio_programada,
    EI.end_date AS fecha_fin_programada,
    E.update_date AS fecha_actualizacion_monto,
    E.amount as monto,
    ET.event_desc AS tipo,
    EI.payment_day as dia_pago,
    PI.payment_limit_day,
    PI.payment_lapse,
    BI.bank_desc AS banco_asociado,
    CT.card_type_desc AS tipo_tarjeta_asoc,
    E.ind_active AS ind_activo
  FROM stg.EVENT_INFORMATION EI
    LEFT JOIN stg.EVENT E
    ON EI.USER_ID = E.USER_ID
      AND EI.EVENT_ID = E.EVENT_ID
    LEFT JOIN stg.EVENT_TYPE ET
    ON EI.EVENT_TYPE = ET.ID
    LEFT JOIN stg.PAYMENT_INFORMATION PI
    ON EI.PAYMENT_ID = PI.PAYMENT_ID
    LEFT JOIN stg.BANK_INFORMATION BI
    ON PI.BANK_ID = BI.BANK_ID
    LEFT JOIN stg.CARD_TYPES CT
    ON PI.CARD_TYPE_ID = CT.CARD_TYPE_ID
    LEFT JOIN stg.RECURRENCES R
    ON EI.RECURRENCE = R.RECURRENCE_ID
  WHERE
   EI.USER_ID = user_
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION stg.tf_get_events_updates( user_ integer)
RETURNS 
TABLE (
  user_id integer,
  event_id integer,
  event_type integer,
  recurrence_id integer,
  event_desc varchar(50),
  event_start_dt date,
  event_end_dt date,
  amount_start_dt date,
  amount_end_dt date,
  amount decimal(10,3),
  card_type_id integer,
  payment_day integer,
  payment_limit_day integer,
  effective_transac_day integer,
  payment_lapse integer
  )
AS
$$
  SELECT
    EI.user_id,
    EI.event_id,
    EI.event_type,
    EI.RECURRENCE AS recurrence_id,
    EI.event_desc,
    CASE
      WHEN EI.start_date IS NULL THEN EI.signup_date
      ELSE EI.signup_date END AS event_start_dt,
    EI.end_date AS event_end_dt,
    E.start_dt AS amount_start_dt,
    E.end_dt  AS amount_end_dt,
    E.amount,
    PI.CARD_TYPE_ID,
    EI.payment_day,
    PI.payment_limit_day,
    CASE
      WHEN PI.CARD_TYPE_ID IN (1,3)--tarjeta con fecha de pago fijo
      THEN PI.payment_limit_day
      WHEN EI.RECURRENCE IN (-1, 3)
    --transacciones unicas y mensuales no asociadas a tarjetas con fechas
      THEN EI.payment_day
    END AS effective_transac_day,
    COALESCE(PI.payment_lapse, 0)
  FROM stg.EVENT_INFORMATION EI
    LEFT JOIN
    (
      SELECT
    	  user_id,
    	  event_id,
    	  amount,
    	  update_date AS start_dt,
    	  LEAD(update_date) OVER(
    	  	PARTITION BY event_id
    	  	ORDER BY update_date
    	  	)-1 AS end_dt,
    	  ind_active
      FROM stg.EVENT
      --WHERE ind_active <> 0
    ) E
    ON EI.USER_ID = E.USER_ID
      AND EI.EVENT_ID = E.EVENT_ID
    LEFT JOIN stg.PAYMENT_INFORMATION PI
    ON EI.PAYMENT_ID = PI.PAYMENT_ID
  WHERE EI.user_id = user_
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION stg.get_event_facts(user_id integer, start_dt date, end_dt date)
RETURNS
TABLE (
  effective_dt date,
  cutoff_dt date,
  user_id integer,
  event_id integer,
  event_type integer,
  recurrence_id integer,
  card_type_id integer,
  amount decimal(10,3),
  payment_lapse integer,
  payment_day integer
)
AS $$
SELECT
	time_tbl.period_dt as effective_dt,
	time_tbl.period_dt - events.payment_lapse as cutoff_dt,
	events.user_id,
	events.event_id,
	events.event_type,
	events.recurrence_id,
	events.card_type_id,
	events.amount,
	events.payment_lapse,
  events.payment_day
FROM public.dim_events events
  LEFT JOIN
  (
  	SELECT
  		date_trunc('day',d)::date AS period_dt
  	FROM generate_series($2, $3, INTERVAL '1 DAY') d
  ) time_tbl
  ON
    time_tbl.period_dt - events.payment_lapse BETWEEN events.event_start_dt AND COALESCE(events.event_end_dt, current_date)
    AND time_tbl.period_dt - events.payment_lapse BETWEEN events.amount_start_dt AND COALESCE(events.amount_end_dt, current_date)
WHERE
  events.user_id = $1 AND
  CASE
  WHEN events.recurrence_id = -1 --transaccion unica
  THEN 
    EXTRACT(DAY FROM time_tbl.period_dt) = events.effective_transac_day
    AND time_tbl.period_dt <= LAST_DAY((events.event_start_dt + interval '1 month')::date)
	AND (DATE_TRUNC('month', events.event_start_dt)::date -1 + events.payment_day)::date < time_tbl.period_dt
  WHEN events.recurrence_id = 1 --bisemanal
  THEN
    EXTRACT(DAY FROM time_tbl.period_dt) = 15
    OR time_tbl.period_dt = LAST_DAY(time_tbl.period_dt)
  WHEN events.recurrence_id = 2 --semanal
  THEN
    CAST(to_char(time_tbl.period_dt, 'D') AS integer) = events.effective_transac_day
  WHEN events.recurrence_id = 3 --mensual
  THEN
    EXTRACT(DAY FROM time_tbl.period_dt) = events.effective_transac_day
  END
$$ LANGUAGE SQL;