/*Практическое задание по теме “Транзакции, переменные, представления”*/

/*1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
  Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.*/

CREATE DATABASE IF NOT EXISTS sample;

DROP TABLE IF EXISTS sample.users;

CREATE TABLE sample.users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

TRUNCATE sample.users;

INSERT IGNORE INTO shop.users (id, name, birthday_at) 
VALUES (1, 'Геннадий', '1990-10-05');

START TRANSACTION;

SELECT @uid := u.id, @name := u.name, @birthday_at := u.birthday_at 
  FROM shop.users u 
 WHERE id = 1;

INSERT INTO sample.users (id, name, birthday_at)
VALUES (@uid, @name, @birthday_at);

DELETE 
  FROM shop.users u
 WHERE u.id = 1;

SELECT *
  FROM sample.users;

COMMIT;

/*2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
 * и соответствующее название каталога name из таблицы catalogs.*/

CREATE VIEW prod AS 
 SELECT p.name product_name, c.name catalog_name 
   FROM products p
   JOIN catalogs c ON p.catalog_id = c.id;

SELECT * 
  FROM prod;
 
/*3. (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи 
 * за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит 
 * полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице 
 * и 0, если она отсутствует.*/
 
CREATE VIEW date_info AS
  SELECT august_date.day_date, IF(p.id IS NOT NULL, 1, 0) is_present
    FROM
         (SELECT ('2021-08-01' + INTERVAL c.date_num DAY) AS day_date
            FROM (SELECT singles + tens date_num 
                    FROM (SELECT 0 singles
                           UNION ALL SELECT 1 
                           UNION ALL SELECT 2 
                           UNION ALL SELECT 3
                           UNION ALL SELECT 4 
                           UNION ALL SELECT 5 
                           UNION ALL SELECT 6
                           UNION ALL SELECT 7 
                           UNION ALL SELECT 8 
                           UNION ALL SELECT 9
                         ) singles 
                    JOIN (SELECT 0 tens
                           UNION ALL SELECT 10 
                           UNION ALL SELECT 20 
                           UNION ALL SELECT 30
                         ) tens  
                 ) c  
           WHERE c.date_num BETWEEN 0 and 30) august_date
 LEFT JOIN products p ON august_date.day_date = DATE(created_at)
  ORDER BY august_date.day_date;

SELECT * 
  FROM date_info;
 
/*4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
 * Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.*/
DROP TABLE date_temp;

CREATE TABLE date_temp AS 
SELECT * 
  FROM date_info;

SELECT * 
  FROM date_temp;

START TRANSACTION;

CREATE TEMPORARY TABLE temp AS 
SELECT *
  FROM date_temp
 ORDER BY day_date DESC
 LIMIT 5;

DELETE 
  FROM date_temp
 WHERE day_date NOT IN (SELECT day_date FROM temp);

DROP TEMPORARY TABLE temp;

COMMIT;

 
 