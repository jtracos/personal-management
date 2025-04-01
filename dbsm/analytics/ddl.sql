CREATE OR REPLACE TABLE public.dim_events(
  user_id integer,
  event_id integer,
  event_type integer,
  recurrence_id integer,
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