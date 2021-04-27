-- ====================================================== --
/* Практическое задание по теме “Оптимизация запросов” */
-- ====================================================== --
/* 1. Создайте таблицу logs типа Archive. Пусть при каждом создании 
 * записи в таблицах users, catalogs и products в таблицу logs помещается время и дата 
 * создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name. */

-- PRIMARY KEY не указываем, т.к. ARCHIVE не поддерживает индексы
DROP TABLE IF EXISTS logs; -- удаляем таблицу, если она уже имеется
CREATE TABLE logs ( -- создаем таблицу заново
	created_at DATETIME NOT NULL,
	table_name VARCHAR(45) NOT NULL,
	str_id BIGINT(20) NOT NULL,
	name_value VARCHAR(45) NOT NULL
) ENGINE = ARCHIVE; -- указываем тип таблицы ARCHIVE

-- Создаем триггер для ведения логов при создании записей в таблицу users

DROP TRIGGER IF EXISTS log_users; -- удаляем триггер в случае, если он уже есть 
DELIMITER // -- меняем "отделитель" на // 
CREATE TRIGGER log_users AFTER INSERT ON users -- создаем триггер
FOR EACH ROW
BEGIN
	INSERT INTO logs (created_at, table_name, str_id, name_value) -- вносим в таблицу logs
	VALUES (NOW(), 'users', NEW.id, NEW.name); -- текущее время, название таблицы (в данном случае users), id пользователя и его имя
END // -- завершаем триггер
DELIMITER ; -- возвращаем ; в качестве "отделителя"

-- Создаем триггер для ведения логов при создании записей в таблицу catalogs

DROP TRIGGER IF EXISTS log_catalogs; -- удаляем триггер в случае, если он уже есть 
DELIMITER // -- меняем "отделитель" на // 
CREATE TRIGGER log_catalogs AFTER INSERT ON catalogs -- создаем триггер
FOR EACH ROW
BEGIN
	INSERT INTO logs (created_at, table_name, str_id, name_value) -- вносим в таблицу logs
	VALUES (NOW(), 'catalogs', NEW.id, NEW.name); -- текущее время, название таблицы (в данном случае catalogs), id каталога и его название
END // -- завершаем триггер
DELIMITER ; -- возвращаем ; в качестве "отделителя"

-- Создаем триггер для ведения логов при создании записей в таблицу products

DROP TRIGGER IF EXISTS log_products; -- удаляем триггер в случае, если он уже есть 
DELIMITER // -- меняем "отделитель" на // 
CREATE TRIGGER log_products AFTER INSERT ON products -- создаем триггер
FOR EACH ROW
BEGIN
	INSERT INTO logs (created_at, table_name, str_id, name_value) -- вносим в таблицу logs
	VALUES (NOW(), 'products', NEW.id, NEW.name); -- текущее время, название таблицы (в данном случае products), id товара и его название
END // -- завершаем триггер
DELIMITER ; -- возвращаем ; в качестве "отделителя"

-- Готово :) теперь внесём немного новых данных в таблицы users, catalogs и products, чтобы убедиться, что всё работает

INSERT INTO users (name, birthday_at)
VALUES ('Иван', '1991-01-01'),
		('Пётр', '1994-02-02'),
		('Фёдор', '1990-03-07'),
		('Евстигней', '1999-08-08');

INSERT INTO catalogs (name)
VALUES ('Всякая всячина'),
		('Разные полезности'),
		('То, что никто не купит');

INSERT INTO products (name, description, price, catalog_id)
VALUES ('Губы рыбы', 'Всякая всячина', 99000.00, 13),
		('Жабьи глазки', 'Разные полезности', 101101.00, 14),
		('Содержимое Александрийской библиотеки', 'То, что никто не купит', 999999999.00, 15);

-- Проверим, что у нас в итоге получилось
SELECT * FROM users;
SELECT * FROM catalogs;
SELECT * FROM products;
SELECT * FROM logs;

-- Успешный успех, оно работает, логи пишутся :)

/* 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей. */

-- На самом деле, 1000000 пользователей, звучит как смертный приговор для моего несчастного пылесоса, который по ошибке называется ПК :)
-- поэтому попробуем начать с 100 пользователей)
-- Есть мнение, что под каждую попытку стоит создавать свою таблицу
-- для 100
DROP TABLE IF EXISTS users_100; 
CREATE TABLE users_100 (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Для внесения пользователей напишем небольшую процедуру) можно было бы воспользоваться filldb.info, но это же слишком просто :D

DROP PROCEDURE IF EXISTS easy_users_100; -- удаляем процедуру, если она уже есть
delimiter // -- меняем "отделитель" на // 
CREATE PROCEDURE easy_users_100 () -- создаем процедуру 
BEGIN
	DECLARE i INT DEFAULT 100; -- задаем конечное число пользователей
	DECLARE j INT DEFAULT 0; -- задаем точку отсчёта
	WHILE i > 0 DO -- пока счетчик не дойдёт до нуля
		INSERT INTO users_100(name, birthday_at) VALUES (CONCAT('experimental_', j), NOW()); -- вносим в таблицу пользователя с именем подопытный_j (например, experimental_0) и текущей датой в качестве др
		SET j = j + 1; -- добавляем 1 к текущему значению счётчика
		SET i = i - 1; -- отнимаем 1 от оставшегося числа пользователей
	END WHILE; -- завершение цикла WHILE
END // -- завершение процедуры
delimiter ; -- возвращаем ; в качестве "отделителя"

-- проверяем, что получилось

CALL easy_users_100();
-- 192 ms - время выполнения скрипта, 32К - "вес" таблицы
SELECT * FROM users_100 LIMIT 3; -- просто убедимся, что всё работает :)

-- усложним задачку - добавим 10 000 пользователей)
-- логика та же

DROP TABLE IF EXISTS users_10000; 
CREATE TABLE users_10000 (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS easy_users_10000; -- удаляем процедуру, если она уже есть
delimiter // -- меняем "отделитель" на // 
CREATE PROCEDURE easy_users_10000 () -- создаем процедуру 
BEGIN
	DECLARE i INT DEFAULT 10000; -- задаем конечное число пользователей
	DECLARE j INT DEFAULT 0; -- задаем точку отсчёта
	WHILE i > 0 DO -- пока счетчик не дойдёт до нуля
		INSERT INTO users_10000(name, birthday_at) VALUES (CONCAT('experimental_', j), NOW()); -- вносим в таблицу пользователя с именем подопытный_j (например, experimental_0) и текущей датой в качестве др
		SET j = j + 1; -- добавляем 1 к текущему значению счётчика
		SET i = i - 1; -- отнимаем 1 от оставшегося числа пользователей
	END WHILE; -- завершение цикла WHILE
END // -- завершение процедуры
delimiter ; -- возвращаем ; в качестве "отделителя"

-- проверяем, что получилось

CALL easy_users_10000();
-- 15875 ms, т.е. 15,88 с - время выполнения скрипта, 1.7М - "вес" таблицы
SELECT * FROM users_10000 LIMIT 3;

-- Снова поднимем ставки, добавим 100 000 пользователей, просто потому что мы можем

DROP TABLE IF EXISTS users_100000; 
CREATE TABLE users_100000 (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS easy_users_100000; -- удаляем процедуру, если она уже есть
delimiter // -- меняем "отделитель" на // 
CREATE PROCEDURE easy_users_100000 () -- создаем процедуру 
BEGIN
	DECLARE i INT DEFAULT 100000; -- задаем конечное число пользователей
	DECLARE j INT DEFAULT 0; -- задаем точку отсчёта
	WHILE i > 0 DO -- пока счетчик не дойдёт до нуля
		INSERT INTO users_100000(name, birthday_at) VALUES (CONCAT('experimental_', j), NOW()); -- вносим в таблицу пользователя с именем подопытный_j (например, experimental_0) и текущей датой в качестве др
		SET j = j + 1; -- добавляем 1 к текущему значению счётчика
		SET i = i - 1; -- отнимаем 1 от оставшегося числа пользователей
	END WHILE; -- завершение цикла WHILE
END // -- завершение процедуры
delimiter ; -- возвращаем ; в качестве "отделителя"

-- проверяем, что получилось

CALL easy_users_100000();
-- 148157 ms, т.е. 148,16 с, т.е. 2 мин 28 с - время выполнения скрипта, 8М - "вес" таблицы
SELECT * FROM users_100000 LIMIT 3;

-- Ну и, наконец, "Всё на Zero", добавим 1 000 000 пользователей

DROP TABLE IF EXISTS users_million; 
CREATE TABLE users_million (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS easy_users_million; -- удаляем процедуру, если она уже есть
delimiter // -- меняем "отделитель" на // 
CREATE PROCEDURE easy_users_million () -- создаем процедуру 
BEGIN
	DECLARE i INT DEFAULT 1000000; -- задаем конечное число пользователей
	DECLARE j INT DEFAULT 0; -- задаем точку отсчёта
	WHILE i > 0 DO -- пока счетчик не дойдёт до нуля
		INSERT INTO users_million(name, birthday_at) VALUES (CONCAT('experimental_', j), NOW()); -- вносим в таблицу пользователя с именем подопытный_j (например, experimental_0) и текущей датой в качестве др
		SET j = j + 1; -- добавляем 1 к текущему значению счётчика
		SET i = i - 1; -- отнимаем 1 от оставшегося числа пользователей
	END WHILE; -- завершение цикла WHILE
END // -- завершение процедуры
delimiter ; -- возвращаем ; в качестве "отделителя"

-- проверяем, что получилось

CALL easy_users_million();
-- 1488550 ms, т.е. 1488,5 с, т.е. 24 мин 48 с - время выполнения скрипта, 74М - "вес" таблицы
SELECT * FROM users_million LIMIT 3;
-- не так уж и страшно, всего 28,8 минут :)

-- ====================================================== --
/* Практическое задание по теме “NoSQL” */
-- ====================================================== --
/* 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов. */
-- я решил решения по Redis внести в этот же sql-файл, чтобы не плодить помойку в гите) 
-- Под "подберите коллекцию" я понял просто создание коллекции, содержащей несколько разных IP-адресов, по которой потом можно осуществить поиск

SADD ip '77.37.27.122' '217.152.45.23' '77.38.29.188' -- добавляем ip адреса
SMEMBERS ip -- смотрим, какие адреса у нас есть
SCARD ip -- считаем количество адресов

/* 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени. */
-- Так как Redis не позволяет использовать в запросах значения, получается,  поиск можно производить только по ключу, то
-- есть задача подразумевает под собой два решения
-- 1) Поиск имени по адресу
set example@example.com Petr -- заводим пользователя
get example@example.com  -- находим имя
-- 2) Поиск адреса по имени
set Petr example@example.com -- заводим пользователя
get Petr -- находим его почтовый адрес

/* 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB. */
-- После плясок с бубном поставил MongoDB, в качестве GUI использовал Robo3T - классная штука для управления MongoDB под Win10
use products -- используем таблицу products
db.products.insert({"name": "Intel Core i7-9900", "description": "Процессор для настольных ПК", "price": "26000.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()})  -- добавляем 1 процессор в качестве товара

db.products.insertMany([
	{"name": "Intel Pentium Gold", "description": "Процессор для настольных ПК", "price": "12000.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()},
	{"name": "Intel Xeon Gold 6134M", "description": "Процессор для серверов", "price": "450000.00", "catalog_id": "Процессоры", "created_at": new Date(), "updated_at": new Date()}]) -- добавляем еще пачку процессоров :)

db.products.find().pretty() -- показываем всё, что есть в таблице products
db.products.find({name: "Intel Xeon Gold 6134M"}).pretty() -- находим в таблице информацию по камню с названием "Intel Xeon Gold 6134M"

use catalogs -- переключаемся на таблицу catalogs
db.catalogs.insertMany([{"name": "Процессоры"}, {"name": "Материнские платы"}, {"name": "Видеокарты"}]) -- добавляем в неё категории товаров 

-- вроде как выполнил, не уверен что правильно, но я хотя бы попытался :D