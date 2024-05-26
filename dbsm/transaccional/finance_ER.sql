DROP SCHEMA IF EXISTS finance;
CREATE SCHEMA IF NOT EXISTS finance;

USE finance;

CREATE TABLE IF NOT EXISTS USERS(
 user_id bigint,
 user_name varchar(50) not null,
 first_name varchar(50) null,
 last_name varchar(50) null,
 birth_date date not null,
 signup_date DATE  not null,
 is_active boolean not null,
 update_date date null,
 constraint PK_USER primary key(user_id)
);


CREATE TABLE IF NOT EXISTS RECURRENCES(
recurrence_id tinyint check( recurrence_id in (-1,0,1,2)),
recurrence_desc varchar(50),
update_date date not null,
constraint PK_RECURRENCE primary key(recurrence_id)
);

CREATE TABLE IF NOT EXISTS BANK_INFORMATION(
bank_id int,
bank_desc varchar(40),
constraint PK_BANK primary key(bank_id)
);

CREATE TABLE CARD_TYPES(
card_type_id int check( card_type_id in (-1, 0,1,2,3)),
card_type_desc VARCHAR(30),
constraint PK_CARD_TYPE primary key(card_type_id)
);

CREATE TABLE PAYMENT_INFORMATION(
user_id bigint,
bank_id int,
card_type_id int check( card_type_id in (-1,1,2,3)),
payment_limit_day int,
payment_lapse int,
update_date date not null,
constraint PK_PAYMENTS primary key(bank_id,user_id,card_type_id),
constraint FK_USER foreign key(user_id) references USERS(user_id),
constraint FK_CARD_TYPE foreign key(card_type_id) references CARD_TYPES(card_type_id),
constraint FK_BANK foreign key(bank_id) references BANK_INFORMATION(bank_id)
);

CREATE TABLE IF NOT EXISTS INCOMES_INFORMATION(
user_id bigint,
income_id int,
update_date date,
amount decimal(10,3),
is_periodic boolean not null,
recurrence tinyint not null check( recurrence in (-1,0,1,2)) default -1,
income_desc varchar(50),
constraint FK_INCOMES_RECURRENCE foreign key(recurrence) references RECURRENCES(recurrence_id),
constraint PK_INCOMES_INFO primary key (user_id, income_id, update_date)
);

CREATE TABLE IF NOT EXISTS INCOMES(
user_id bigint,
income_id int,
bank_id int default -1,
card_type_id int check( card_type_id in (-1,2)) default -1,
update_date date not null,
constraint FK_INCOMES_USER foreign key(user_id) references USERS(user_id),
constraint FK_INCOMES_INCOMES_INFO foreign key(user_id,income_id) references INCOMES_INFORMATION(user_id,income_id),
constraint FK_INCOMES_PAYMENT foreign key(user_id,bank_id,card_type_id) references PAYMENT_INFORMATION(user_id,bank_id,card_type_id)
-- constraint UNIQUE_PK unique(user_id, income_id)
);

CREATE TABLE IF NOT EXISTS OUTCOMES_INFORMATION(
user_id bigint,
outcome_id int,
recurrence tinyint not null check( recurrence in (-1,0,1,2)) default -1,
amount decimal(10,3),
update_date date not null,
start_date date null,
end_date date null,
payment_day int null,
is_periodic boolean not null,
outcome_desc varchar(50),
constraint FK_OUTCOMES_RECURRENCE foreign key(recurrence) references RECURRENCES(recurrence_id),
constraint PK_OUTCOMES_INFO primary key(user_id,outcome_id,update_date)
);


CREATE TABLE IF NOT EXISTS OUTCOMES(
user_id bigint,
outcome_id int,
card_type_id int check( card_type_id in (-1, 1, 2, 3)) default -1,
bank_id int default -1,
update_date date not null,
constraint FK_OUTCOMES_USER foreign key(user_id) references USERS(user_id),
constraint FK_OUTCOMES_INFO foreign key (user_id, outcome_id) references OUTCOMES_INFORMATION(user_id, outcome_id),
constraint FK_OUTCOMES_PAYMENT foreign key(user_id, bank_id, card_type_id) references PAYMENT_INFORMATION(user_id, bank_id, card_type_id)
-- constraint UNIQUE_PK unique(user_id, outcome_id)
);