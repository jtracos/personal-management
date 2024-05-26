USE finance;

INSERT INTO USERS(user_id, user_name, first_name, last_name, birth_date, signup_date, is_active)
VALUES
(1, "JOSUE", "TRINIDAD","ACOSTA", "1996-07-22","2024-01-06",true);

INSERT INTO RECURRENCES(recurrence_id, recurrence_desc, update_date)
VALUES
(0, "BIWEEKLY","2024-01-07"),
(1, "WEEKLY","2024-01-07"),
(2, "MONTHLY","2024-01-07"),
(-1, "NA","2024-01-07");

INSERT INTO BANK_INFORMATION(bank_id, bank_desc)
VALUES

(1, "BBVA"),
(2,"NU BANK"),
(-1,"N/A"),
(3,"COPPEL")
;

INSERT INTO CARD_TYPES(card_type_id,card_type_desc)
VALUES
(-1 , "NA"),
(1, "CREDITO"),
(2, "DEBITO"),
(3, "DEPARTAMENTAL")
;
-- SELECT * FROM PAYMENT_INFORMATION;
INSERT INTO PAYMENT_INFORMATION(user_id, bank_id, card_type_id, payment_limit_day, payment_lapse, update_date)
VALUES
(1, 1, 1,28,20,"2024-01-07"),
(1,2,1,10,10,"2024-01-07"),
(1, 1, 2, null, null,"2024-01-07"),
(1,2,2, null, null,"2024-01-07"),
(1,-1,-1, null, null,"2024-01-07"),
(1,3,3, null, null,"2024-01-16")
;
SELECT * FROM INCOMES_INFORMATION;
INSERT INTO INCOMES_INFORMATION(
user_id,income_id,update_date, amount,is_periodic, recurrence, income_desc)
VALUES
(1, 1, "2024-01-07", 10118, true, 0, "NOMINA IDS"),
(1, 1, '2024-01-12', 11268, 1, 0, 'NOMINA IDS');

INSERT INTO OUTCOMES_INFORMATION(
user_id,outcome_id,recurrence,amount,update_date,start_date,end_date,payment_day,is_periodic,outcome_desc
)
VALUES
(1,	1, -1, 2297, "2023-12-21", "2023-12-31", null,null, false,"Carinosas"),
(1, 2, 2,150,"2024-01-07", "2023-05-10", "2024-05-10",null, true,"Barra sonido"),
(1, 3, 2,246,"2024-01-07", "2023-02-05", "2024-02-05",null, true, "Licuadora ninja"),
(1, 4, 2,514,"2024-01-07", "2023-12-19", "2024-12-19",null, true,"Star link"),
(1, 5, 2,389,"2024-01-07", "2023-05-02", "2024-11-02",null, true, "Tv Jvc"),
(1, 6, 2,615.29,"2024-01-07", "2023-10-21", "2025-04-21",null, true,"Prestamo BBVA"),
(1, 7, 2,514.03,"2024-01-07", "2023-11-23", "2024-11-23",null, true, "Prestamo BBVA"),
(1, 8, 2,1068.30,"2024-01-07", "2024-01-26", "2025-01-26",null, true,"Prestamo BBVA"),
(1, 9, 2,2500,"2024-01-08", "2024-01-09", null,9, true,"Renta"),
(1, 10, 2,400,"2024-01-08", "2024-01-15", null,15, true,"Internet"),
(1, 11, 0,601,"2024-01-08", "2023-09-11", "2029-09-11",null, true,"Prestamo personal BBVA"),
(1, 12, 2,99,"2024-01-12", "2024-01-12", null,null, true,"membresia crunchy roll"),
(1, 13, 2,1100,"2024-01-12", "2023-12-20", null,null, true,"Servicio star link"),
(1, 14, 2,675,"2024-01-12", "2024-01-01", "2025-01-01",null, true,"IPhone"),
(1, 15, 2,1170,"2024-01-15", "2024-01-15", "2025-01-14",15, true,"Moto");

INSERT INTO INCOMES(user_id, income_id, bank_id, card_type_id, update_date)
VALUES
(1, 1, 1, 2, "2024-01-07");

INSERT INTO OUTCOMES(
user_id, outcome_id, card_type_id, bank_id, update_date)
VALUES
(1, 1, 1, 1, "2024-01-07"),
(1, 2, 1, 1, "2024-01-07"),
(1, 3, 1, 1, "2024-01-07"),
(1, 4, 1, 1, "2024-01-07"),
(1, 5, 1, 1, "2024-01-07"),
(1, 6, 1,1, "2024-01-07"),
(1, 7, 1,1, "2024-01-07"),
(1, 8, 1,1, "2024-01-07"),
(1, 9, -1,-1, "2024-01-07"),
(1, 10, -1,-1, "2024-01-07"),
(1, 11,2,1, "2024-01-07"),
(1, 12,1,2, "2024-01-12"),
(1, 13,1,1, "2024-01-12"),
(1, 14,1,2, "2024-01-12"),
(1, 15,3,3, "2024-01-15");

/*
SELECT * FROM USERS;
SELECT * FROM RECURRENCES;
SELECT * FROM CARD_TYPES;
SELECT * FROM PAYMENT_INFORMATION;
SELECT * FROM INCOMES_INFORMATION;
SELECT * FROM OUTCOMES_INFORMATION:
SELECT * FROM INCOMES;
SELECT * FROM OUTCOMES;
SELECT * FROM BANK_INFORMATION;
*/