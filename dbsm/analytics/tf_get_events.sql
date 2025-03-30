CREATE OR REPLACE FUNCTION public.tf_get_events( user_ integer)
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
WHERE
 EI.USER_ID = user_
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION public.tf_get_events_updates( user_ integer)
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