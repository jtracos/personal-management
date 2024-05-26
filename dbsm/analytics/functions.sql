create function last_day(date)
returns date as
$$
select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date;
$$ language 'sql'
immutable strict;

create function month_esp(date)
returns text as
$$
select
  CASE
    WHEN extract(month from $1) = 1 THEN 'ENERO'
    WHEN extract(month from $1) = 2 THEN 'FEBRERO'
    WHEN extract(month from $1) = 3 THEN 'MARZO'
    WHEN extract(month from $1) = 4 THEN 'ABRIL'
    WHEN extract(month from $1) = 5 THEN 'MAYO'
    WHEN extract(month from $1) = 6 THEN 'JUNIO'
    WHEN extract(month from $1) = 7 THEN 'JULIO'
    WHEN extract(month from $1) = 8 THEN 'AGOSTO'
    WHEN extract(month from $1) = 9 THEN 'SEPTIEMBRE'
    WHEN extract(month from $1) = 10 THEN 'OCTUBRE'
    WHEN extract(month from $1) = 11 THEN 'NOVIEMBRE'
    WHEN extract(month from $1) = 12 THEN 'DICIEMBRE'
  END;
$$ language 'sql'
immutable strict