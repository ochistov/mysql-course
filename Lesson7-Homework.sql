USE x; -- используем БД, созданную из hw-7-data.sql
/* 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине. */
SELECT -- выводим
	users.id AS user_id, -- id пользователя 
	users.name AS user_name, -- имя пользователя
	orders_products.order_id AS order_id, -- id заказа
	orders_products.product_id AS product_id, -- id товара
	(SELECT name 
		FROM products 
		WHERE id = orders_products.product_id) AS product_name, -- наименование товара
	orders_products.total -- количество приобретённого пользователем товара
FROM (users
	LEFT JOIN orders -- объединяем таблицы users и orders 
	ON users.id = orders.user_id
	LEFT JOIN orders_products -- присоединяем таблицу orders_products
	ON orders.id = orders_products.order_id)
ORDER BY users.name, orders_products.order_id; -- сортируем по имени пользователя и id заказа
-- в задании этого не было, но я решил, что было бы логично выводить помимо пользователей и номера заказа ещё и наименование товара с количеством :)

/* 2. Выведите список товаров products и разделов catalogs, который соответствует товару. 
 * Имейте ввиду, у продукта может не быть каталога, однако выводить такой продукт все равно необходимо. */
SELECT -- выбираем
	products.id, -- id товара
	products.name, -- наименование товара
	products.price, -- цену товара
	catalogs.id AS cat_id, -- id каталога
	catalogs.name AS catalog -- название каталога
FROM
	products
LEFT JOIN -- соединяем таблицы products и catalogs
	catalogs
ON 
	products.catalog_id = catalogs.id;
-- Не увидел сложности в выводе товаров с catalogs.id = NULL :) 
-- Скорее всего, они возникают у тех, кто использует не LEFT JOIN, а просто JOIN

/* 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
 * Поля from, to и label содержат английские названия городов, поле name — русское. 
 * Выведите список рейсов flights с русскими названиями городов. */
-- Для начала создадим БД task3, в которой будем работать

CREATE DATABASE IF NOT EXISTS task3;
USE task3;
-- Создадим указанные в задании таблицы
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
	label VARCHAR(255) PRIMARY KEY, 
	name VARCHAR(255)
);
CREATE TABLE flights(
	id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`from` VARCHAR(255) NOT NULL, 
	`to` VARCHAR(255) NOT NULL,
	CONSTRAINT fk_from_label FOREIGN KEY(`from`) REFERENCES cities(label),
	CONSTRAINT fk_to_label FOREIGN KEY(`to`) REFERENCES cities(label)
);
-- Заполним таблицу cities по картинке из задания
INSERT INTO cities VALUES
	('moscow', 'Москва'),
	('irkutsk', 'Иркутск'),
	('novgorod', 'Новгород'),
	('kazan', 'Казань'),
	('omsk', 'Омск');
-- Заполним таблицу flights значениями из задания
INSERT INTO flights VALUES
	(DEFAULT, 'moscow', 'omsk'),
	(DEFAULT, 'novgorod', 'kazan'),
	(DEFAULT, 'irkutsk', 'moscow'),
	(DEFAULT, 'omsk', 'irkutsk'),
	(DEFAULT, 'moscow', 'kazan');
-- Собственно, решение
SELECT
	id AS flight_id,
	(SELECT name FROM cities WHERE label = `from`) AS 'from', -- Подставляем русские названия городов в столбец from
	(SELECT name FROM cities WHERE label = `to`) AS 'to' -- Подставляем русские названия городов в столбец to
FROM
	flights
ORDER BY
	flight_id; -- сортируем по id рейса

