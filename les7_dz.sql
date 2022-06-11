/*1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.*/

SELECT DISTINCT users.id, users.name 
  FROM users
  JOIN orders
    ON users.id = user_id;
    
 /*2. Выведите список товаров products и разделов catalogs, который соответствует товару.*/
   
SELECT p.id, p.name, c.name  
  FROM products AS p 
  JOIN catalogs AS c 
    ON catalog_id = c.id;
    
/*3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
 * Поля from, to и label содержат английские названия городов, поле name — русское. 
 * Выведите список рейсов flights с русскими названиями городов.*/
   
SELECT id, 
	   (SELECT name 
	      FROM cities
	     WHERE label = from_city) AS 'from',
	   (SELECT name 
	      FROM cities
	     WHERE label = to_city) AS 'to'
  FROM flights;
  
