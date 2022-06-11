-- Работаем с БД shop
/*Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение”*/

/* 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.*/
UPDATE users 
   SET created_at = NOW(), 
       updated_at = NOW();
       
/* 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в 
 * формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения. */

-- Для моделирования ситуации создаем и наполняем таблицу users2

DROP TABLE IF EXISTS users2;

CREATE TABLE users2
      SELECT id, name, birthday_at FROM users;

ALTER TABLE users2
 ADD COLUMN created_at VARCHAR(20), 
 ADD COLUMN updated_at VARCHAR(20);
 
UPDATE users2 
   SET created_at = DATE_FORMAT(NOW(), '%d.%m.%Y %H:%i'), 
       updated_at = DATE_FORMAT(NOW(), '%d.%m.%Y %H:%i');

-- Создаем два новых столбца с нужным типом и переносим данные
ALTER TABLE users2
 ADD COLUMN created_at_new DATETIME,
 ADD COLUMN updated_at_new DATETIME;

UPDATE users2 
   SET created_at_new = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), 
       updated_at_new = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');
      
ALTER TABLE users2
DROP COLUMN created_at,
DROP COLUMN updated_at;

  ALTER TABLE users2
RENAME COLUMN created_at_new TO created_at,
RENAME COLUMN updated_at_new TO updated_at;

/*3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, 
 * если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
 * Однако, нулевые запасы должны выводиться в конце, после всех записей.*/

-- Наполним таблицу storehouses_products

INSERT INTO storehouses_products (value)
VALUES (0),
	   (2500),
	   (0),
	   (30),
	   (500),
	   (1);

-- Вывод отсортированных значений
SELECT * 
  FROM storehouses_products 
 ORDER BY IF(value = 0, 1, 0), value;

/*4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
 * Месяцы заданы в виде списка английских названий ('may', 'august')*/

SELECT * 
  FROM users
 WHERE DATE_FORMAT(birthday_at, '%M') = 'May' OR DATE_FORMAT(birthday_at, '%M') = 'August';

/*5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs 
 * WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.*/

SELECT * 
  FROM catalogs 
 WHERE id IN (5, 1, 2) 
 ORDER BY FIELD(id, 5, 1, 2);

/*Практическое задание теме “Агрегация данных”*/
/*1. Подсчитайте средний возраст пользователей в таблице users*/

SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW()))
  FROM users;
  
/*2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
 * Следует учесть, что необходимы дни недели текущего года, а не года рождения.*/
 
SELECT DAYNAME(TIMESTAMPADD(YEAR, YEAR(NOW()) - YEAR(birthday_at), birthday_at)) AS week_day,
	   COUNT(*) AS quantity
  FROM users
 GROUP BY week_day;
 
/*3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.*/
-- Создадим таблицу

CREATE TABLE tbl (
	id SERIAL PRIMARY KEY,
	value INT DEFAULT NULL);

INSERT tbl (value)
VALUES (1),
	   (2),
	   (3),
	   (4),
	   (5);

-- Поскольку готовой функции агрегации нет, считаем через логарифмирование (варианты с отрицительными числами и NULL не учел, поскольку их нет в задании)
SELECT exp(SUM(log(value))) AS multiplication FROM tbl;
