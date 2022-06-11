/*Практическое задание по теме “Хранимые процедуры и функции, триггеры"*/

/*1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
 С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи". */
DROP PROCEDURE IF EXISTS hello;

DELIMITER //

CREATE PROCEDURE hello()
 BEGIN
 	SELECT CASE 
 		    WHEN TIME(NOW()) BETWEEN '06:00:01' AND '12:00:00' THEN "Доброе утро"
	 	    WHEN TIME(NOW()) BETWEEN '12:00:01' AND '18:00:00' THEN "Добрый день"
	 	    WHEN TIME(NOW()) BETWEEN '18:00:01' AND '24:00:00' THEN "Добрый вечер" 	 
	 	    WHEN TIME(NOW()) BETWEEN '00:00:01' AND '06:00:00' THEN "Добрый вечер"
	 	   END AS hello;
 END //

CALL hello()//

/*2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие 
 обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, 
 добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.*/
DELIMITER //
DROP TRIGGER IF EXISTS check_name_description//

CREATE TRIGGER check_name_description BEFORE INSERT ON products 
FOR EACH ROW BEGIN
	IF COALESCE(NEW.name, NEW.description) IS NULL THEN 
	   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled!';
	  END IF;
END//

INSERT products (name, description, price, catalog_id)
VALUES (NULL, NULL, 123, 1);

DELIMITER ;
SHOW TRIGGERS;

