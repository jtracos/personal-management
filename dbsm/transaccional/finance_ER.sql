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
recurrence_id tinyint check( recurrence_id in (-1,1,2,3)),
recurrence_desc varchar(50),
update_date date not null,
constraint PK_RECURRENCE primary key(recurrence_id)
);

CREATE TABLE IF NOT EXISTS BANK_INFORMATION(
bank_id int,
bank_desc varchar(40),
constraint PK_BANK primary key(bank_id)
);

CREATE TABLE IF NOT EXISTS CARD_TYPES(
card_type_id int check( card_type_id in (-1,1,2,3)),
card_type_desc VARCHAR(30),
constraint PK_CARD_TYPE primary key(card_type_id)
);

CREATE TABLE IF NOT EXISTS EVENT_TYPE(
    id TINYINT check(id in (1,2) ),
    event_desc VARCHAR(30),
    constraint PK_TYPE primary key(id)
)

CREATE TABLE IF NOT EXISTS PAYMENT_INFORMATION(
payment_id int,
bank_id int,
card_type_id int check( card_type_id in (-1,1,2,3)),
payment_limit_day int,
payment_lapse int,
update_date date not null,
constraint PK_PAYMENTS primary key(payment_id),
constraint FK_CARD_TYPE foreign key(card_type_id) references CARD_TYPES(card_type_id),
constraint FK_BANK foreign key(bank_id) references BANK_INFORMATION(bank_id)
);

CREATE TABLE IF NOT EXISTS EVENT_INFORMATION(
user_id bigint,
event_id int,
payment_id int,
event_type tinyint,
recurrence tinyint not null check( recurrence in (-1,0,1,2)) default -1,
signup_date date not null,
start_date date null,
end_date date null,
duration_month int null,
payment_day int null,
ind_periodic boolean not null check( ind_periodic in (-1, 1)),
ind_active tinyint,
event_desc varchar(50),
constraint PK_EVENT_INFO primary key(user_id,event_id),
constraint FK_EVENT_TYPE foreign key(event_type) references EVENT_TYPE(id),
constraint FK_EVENT_RECURRENCE foreign key(recurrence) references RECURRENCES(recurrence_id),
constraint FK_EVENT_PAYMENTS foreign key (payment_id) references PAYMENT_INFORMATION(payment_id),
constraint FK_EVENT_USER foreign key(user_id) references USERS(user_id)
);

CREATE TABLE IF NOT EXISTS `EVENT`(
user_id bigint,
event_id int,
amount decimal(10,3),
update_date date not null,
constraint FK_EVENT_INFO foreign key(user_id,event_id) references EVENT_INFORMATION(user_id,event_id)
);