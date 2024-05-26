DROP TABLE IF EXISTS incomes, outcomes,incomes_information,
outcomes_information,payment_information, bank_information, card_types, recurrences, users;

CREATE TABLE IF NOT EXISTS USERS(
 user_id bigint,
 user_name varchar(50) not null,
 first_name varchar(50) null,
 last_name varchar(50) null,
 birth_date date not null,
 signup_date DATE  not null,
 is_active int not null check(is_active in (0,1)),
 update_date date null
);


CREATE TABLE IF NOT EXISTS RECURRENCES(
recurrence_id int check( recurrence_id in (-1,0,1,2)),
recurrence_desc varchar(50),
update_date date not null
);

CREATE TABLE IF NOT EXISTS BANK_INFORMATION(
bank_id int,
bank_desc varchar(40)
);

CREATE TABLE IF NOT EXISTS CARD_TYPES(
card_type_id int check( card_type_id in (-1, 0,1,2,3)),
card_type_desc VARCHAR(30));

CREATE TABLE  IF NOT EXISTS PAYMENT_INFORMATION(
user_id bigint,
bank_id int,
card_type_id int check( card_type_id in (-1,1,2,3)),
payment_limit_day int,
payment_lapse int,
update_date date not null);

CREATE TABLE IF NOT EXISTS INCOMES_INFORMATION(
user_id bigint,
income_id int,
update_date date,
amount decimal(10,3),
is_periodic int not null check(is_periodic in (0,1)),
recurrence int not null check( recurrence in (-1,0,1,2)) default -1,
income_desc varchar(50)
);

CREATE TABLE IF NOT EXISTS INCOMES(
user_id bigint,
income_id int,
bank_id int default -1,
card_type_id int check( card_type_id in (-1,2)) default -1,
update_date date not null
/*start_date date not null,
end_date date not null,
*/
);

CREATE TABLE IF NOT EXISTS OUTCOMES_INFORMATION(
user_id bigint,
outcome_id int,
recurrence int not null check( recurrence in (-1,0,1,2)) default -1,
amount decimal(10,3),
update_date date not null,
start_date date null,
end_date date null,
payment_day int null,
is_periodic int not null check(is_periodic in (0,1)),
outcome_desc varchar(50)
);


CREATE TABLE IF NOT EXISTS OUTCOMES(
user_id bigint,
outcome_id int,
card_type_id int check( card_type_id in (-1, 1, 2, 3)) default -1,
bank_id int default -1,
update_date date not null
);
