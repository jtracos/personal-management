CREATE PROCEDURE load_to_dim_events(user_id_ integer)
LANGUAGE SQL
AS $$
  DELETE FROM public.dim_events WHERE user_id = user_id_;
  INSERT INTO public.dim_events(
    user_id,
    event_id,
    event_type,
    recurrence_id,
    event_start_dt,
    event_end_dt,
    amount_start_dt,
    amount_end_dt,
    amount,
    card_type_id,
    payment_day,
    payment_limit_day,
    effective_transac_day,
    payment_lapse
    )
  SELECT
    user_id,
    event_id,
    event_type,
    recurrence_id,
    event_start_dt,
    event_end_dt,
    amount_start_dt,
    amount_end_dt,
    amount,
    card_type_id,
    payment_day,
    payment_limit_day,
    effective_transac_day,
    payment_lapse
  FROM public.tf_get_events_updates(user_id_);
$$
;


CREATE OR REPLACE PROCEDURE stg.load_to_fact_analytic_events(user_id_ integer, start_dt date, end_dt date)
LANGUAGE SQL
AS $$
  DELETE FROM public.fact_analytic_events WHERE user_id = user_id
    AND effective_dt BETWEEN start_dt AND end_dt;
  INSERT INTO public.fact_analytic_events(
    effective_dt,
    cutoff_dt,
    user_id,
    event_id,
    event_type,
    recurrence_id,
    card_type_id,
    amount,
    payment_lapse,
    payment_day,
    real_transaction_dt
  )
  SELECT
    effective_dt,
    cutoff_dt,
    user_id,
    event_id,
    event_type,
    recurrence_id,
    card_type_id,
    amount,
    payment_lapse,
    payment_day,
    CASE
      WHEN payment_day IS NULL THEN cutoff_dt
  	  WHEN DATE_TRUNC('month', cutoff_dt)::date +(payment_day -1) >= cutoff_dt
  	  THEN DATE_TRUNC('month', DATE_TRUNC('month', cutoff_dt)::date -1)::date +(payment_day -1)
  	  ELSE DATE_TRUNC('month', cutoff_dt)::date +(payment_day -1)
    END AS real_transaction_dt
  FROM stg.get_event_facts(user_id_, start_dt, end_dt)
$$