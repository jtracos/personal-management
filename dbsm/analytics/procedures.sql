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