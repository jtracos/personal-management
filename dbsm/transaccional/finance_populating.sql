USE finance;

INSERT INTO USERS(user_id, user_name, first_name, last_name, birth_date, signup_date, ind_active)
VALUES
(1, 'JOSUE', 'TRINIDAD','ACOSTA', '1996-07-22','2024-01-06',true);

INSERT INTO RECURRENCES(recurrence_id, recurrence_desc, update_date)
VALUES
(1, 'BIWEEKLY','2024-01-07'),(2, 'WEEKLY','2024-01-07'),
(3, 'MONTHLY','2024-01-07'),(-1, 'NA','2024-01-07');

INSERT INTO EVENT_TYPE(id, event_desc)
VALUES
(1,'EGRESO'),(2,'INGRESO');

INSERT INTO BANK_INFORMATION(bank_id, bank_desc)
VALUES
(-1,'NA'),(1, 'BBVA'),(2,'NU BANK'),(3,'COPPEL')
;

INSERT INTO CARD_TYPES(card_type_id,card_type_desc)
VALUES
(-1 , 'EFECTIVO'),(1, 'CREDITO'),(2, 'DEBITO'),(3, 'DEPARTAMENTAL')
;
-- SELECT * FROM PAYMENT_INFORMATION;
INSERT INTO PAYMENT_INFORMATION(
    payment_id, bank_id, card_type_id, payment_limit_day, payment_lapse, update_date)
VALUES
(1, 1, 1, 28,20,'2024-01-07'),-- BBVA CREDITO
(2, 2, 1, 5,10,'2024-01-07'),-- NU CREDITO
(3, 1, 2, null, null,'2024-01-07'),-- BBVA DEBITO
(4, 2, 2, null, null,'2024-01-07'),-- NU DEBITO
(5,-1,-1, null, null,'2024-01-07'),-- EFECTIVO NA
(6, 3, 3, null, null,'2024-01-16')-- COPPEL DEPARTAMENTAL
;
INSERT INTO EVENT_INFORMATION(
    user_id,event_id,payment_id,event_type,recurrence,signup_date,
    start_date,end_date,duration_month,payment_day,ind_periodic,
    ind_active,event_desc)
VALUES
(1, 1, 3, 2, 1, '2024-01-07', null, null, null, null, 1, 1, 'NOMINA IDS'),
(1, 2, 2, 1, 1, '2024-01-07', '2023-02-05', '2024-02-05',null,null,1, 1, 'Licuadora ninja'),
(1, 3, 2, 1, 1, '2024-01-07', '2023-12-19', '2024-12-19',null, 21, 1, 1,'Star link'),
(1, 4, 2, 1, 1, '2024-01-08', '2024-01-15', null,null,15, 1, 1,'Internet'),
(1, 5, 1, 1, -1, '2024-01-12', '2024-01-12', null,null,15, 1, 1,'membresia crunchy roll'),
(1, 6, 1, 1, 1, '2024-01-12', '2023-12-20', null,null, 21, 1, 1,'Servicio star link'),
(1, 7, 2, 1, 1, '2024-01-12', '2024-01-01', '2025-01-01',null,null, 1, 1,'IPhone'),
(1, 8, 2, 1, 1, '2024-01-15', '2024-01-15', '2025-01-14',null,15, 1, 1,'Moto'),
(1, 9, 5, 2, 1, '2025-02-07', null, null, null, 20, 1, 1, 'Renta Internet')
;

INSERT INTO `EVENT`(user_id,event_id,amount,update_date)
VALUES
(1, 1, 10118,'2024-01-07'),
(1, 1, 11268,'2024-01-12'),
(1, 2, 246, '2024-01-07'),
(1, 3, 514, '2024-01-07'),
(1, 4, 400, '2024-01-07'),
(1, 5, 99, '2024-01-07'),
(1, 6, 1100, '2024-01-07'),
(1, 7, 675, '2024-01-07'),
(1, 8, 1170, '2024-01-07'),
(1, 9, 950,'2025-02-07')
;