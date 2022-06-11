/*1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, 
 * catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, 
 * идентификатор первичного ключа и содержимое поля name.*/

CREATE TABLE logs (
	logs_id SERIAL,
	table_row_id BIGINT UNSIGNED NOT NULL,
	table_name VARCHAR(100),
	name VARCHAR(255),
	created_at DATETIME NOT NULL DEFAULT NOW()
	) ENGINE = ARCHIVE;

DELIMITER //
CREATE TRIGGER log_users_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
 INSERT INTO logs (table_row_id, table_name, name)
 VALUES (NEW.id, 'users', NEW.name);
END//

DELIMITER //
CREATE TRIGGER log_catalogs_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
 INSERT INTO logs (table_row_id, table_name, name)
 VALUES (NEW.id, 'catalogs', NEW.name);
END//

DELIMITER //
CREATE TRIGGER log_products_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
 INSERT INTO logs (table_row_id, table_name, name)
 VALUES (NEW.id, 'products', NEW.name);
END//

/*2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.*/

DELIMITER //
CREATE PROCEDURE one_million ()
BEGIN 
	DECLARE i INT DEFAULT 1;
	WHILE i <= 1000000 DO
		INSERT users (name, birthday_at)
		VALUES (CONCAT('name','+', i), '3000-01-28');
		SET i = i + 1;
	END WHILE;
END//

CALL one_million(); -- Это очень долго...
