-- ===================================================================== --
-- Практическое задание по теме “Транзакции, переменные, представления”  --
-- ===================================================================== --
/* 1. В базе данных shop и sample присутствуют одни и те же таблицы, 
 * учебной базы данных. Переместите запись id = 1 из таблицы shop.users 
 * в таблицу sample.users. Используйте транзакции. */

-- сделал в 3 вариантах :)
 
-- 1й вариант - база sample уже заполнена, так же, как и база shop из файла shop.sql
-- То есть добавляем запись с id = 1 в конец таблицы sample.users с присвоением нового id.
START TRANSACTION; -- начинаем транзакцию
INSERT INTO sample.users (name, birthday_at) -- добавляем в таблицу sample.users пользователя с именем и др
	SELECT name, birthday_at FROM shop.users WHERE id = 1; -- взятыми из таблицы shop.users у пользователя с id = 1
COMMIT; -- завершаем транзакцию
SELECT * FROM shop.users; -- смотрим, что в таблице shop.users
SELECT * FROM sample.users; -- смотрим, что в таблице sample.users

-- 2й вариант - перенос значения из таблицы shop.users, в конец таблицы sample.users с удалением записи в исходной таблице
START TRANSACTION; -- начинаем транзакцию
INSERT INTO sample.users (name, birthday_at) -- так же, как и
	SELECT name, birthday_at FROM shop.users WHERE id = 1; -- в первом варианте, но теперь
DELETE FROM shop.users -- удаляем из таблицы shop.users пользователя
	WHERE id = 1; -- с id = 1
COMMIT; -- завершаем транзакцию
SELECT * FROM shop.users;
SELECT * FROM sample.users;

-- 3й вариант - перенос записи из таблицы shop.users в sample.users с удалением в первой и заменой исходного значения во второй
START TRANSACTION; -- начинаем транзакцию
DELETE FROM sample.users -- из таблицы sample.users удаляем пользователя
	WHERE id = 1; -- с id = 1
INSERT INTO sample.users -- добаляем в эту же таблицу
	SELECT * FROM shop.users -- целиком строку из таблицы shop.users 
		WHERE id = 1; -- содержащую данные о пользователе с id = 1
DELETE FROM shop.users -- удаляем из shop.users
	WHERE id = 1; -- пользователя с id = 1
COMMIT; -- завершаем транзакцию
SELECT * FROM shop.users;
SELECT * FROM sample.users;
-- Можно продолжать до бесконечности, не очень понятно задание сформулировано:) ну, зато в транзакциях разобрался :D

/* 2. Создайте представление, которое выводит название 
 * name товарной позиции из таблицы products и соответствующее 
 * название каталога name из таблицы catalogs.  */
-- от себя добавил еще вывод id товара, для красоты ^^

CREATE OR REPLACE VIEW products_description(product_id, product_name, catalog_name) AS -- создаём представление
	SELECT products.id, products.name, catalogs.name -- выбираем id товара, его название и название каталога
	FROM products -- из таблицы products
		LEFT JOIN catalogs -- соединённой с таблицей catalogs
		ON products.catalog_id = catalogs.id; -- по полю catalog_id
SELECT * FROM products_description; -- выводим представление

/* 3. по желанию) Пусть имеется таблица с календарным полем created_at. 
 * В ней размещены разряженые календарные записи за август 2018 года 
 * '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
 * Составьте запрос, который выводит полный список дат за август, выставляя 
 * в соседнем поле значение 1, если дата присутствует в исходном 
 * таблице и 0, если она отсутствует. */

-- В задании очепятка, 2016-08-04 - год не 2018, а 2016. Т.к. указано, что август 2018-го, поправил :)

-- Дальше будет немного кошмара, но задание было по желанию, а оно у меня присутствует :D

DROP TABLE IF EXISTS task3;
CREATE TABLE task3 ( -- создаем табличку специально для этого задания
	created_at DATE); -- всего с одним полем created_at с типом данных DATE

INSERT INTO task3 VALUES -- заносим туда значения из задания
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-16'),
	('2018-08-17');

SELECT 
	time_period.selected_date AS day, -- задаем красивое название для столбца с датой
	(SELECT EXISTS(SELECT * FROM task3 WHERE created_at = day)) AS in_task -- проверяем наличие в заданном перечне дат, 0 - FALSE, 1 - TRUE
FROM -- из
	(SELECT alldates.* FROM -- выбираем всё из чудовища ниже
							-- эту громоздкую конструкцию я откопал на stackoverflow в самом тёмном углу
							-- как я понял, это написал какой-то сумасшедший индус и ОНО генерирует ВСЕ 
							-- возможные даты от 01.01.1970 и до победного конца :) 
		(SELECT ADDDATE('1970-01-01',t4.i*10000 + t3.i*1000 + t2.i*100 + t1.i*10 + t0.i) selected_date FROM
			(SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4) AS alldates
	WHERE selected_date BETWEEN '2018-08-01' AND '2018-08-31') AS time_period -- ставим условие, что временной период - август 2018го
ORDER BY day; -- сортируем красивенько по возрастанию
-- получилось громоздко и коряво, но это работает :)

/* 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
 * Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей. */

DROP TABLE IF EXISTS task4; -- создадим таблицу task4
CREATE TABLE task4 (
	created_at DATE); -- с одним полем created_at и типом данных DATE

INSERT INTO task4 VALUES -- добавим туда значений (весь апрель 2021)
	('2021-04-01'),
	('2021-04-02'),
	('2021-04-03'),
	('2021-04-04'),
	('2021-04-05'),
	('2021-04-06'),
	('2021-04-07'),
	('2021-04-08'),
	('2021-04-09'),
	('2021-04-10'),
	('2021-04-11'),
	('2021-04-12'),
	('2021-04-13'),
	('2021-04-14'),
	('2021-04-15'),
	('2021-04-16'),
	('2021-04-17'),
	('2021-04-18'),
	('2021-04-19'),
	('2021-04-20'),
	('2021-04-21'),
	('2021-04-22'),
	('2021-04-23'),
	('2021-04-24'),
	('2021-04-25'),
	('2021-04-26'),
	('2021-04-27'),
	('2021-04-28'),
	('2021-04-29'),
	('2021-04-30');

-- собственно, сам запрос
DELETE FROM task4 -- удаляем из таблицы task4 
WHERE created_at NOT IN ( -- строки, в которых created_at не входит в
	SELECT * -- выборку
	FROM (
		SELECT * -- всего
		FROM task4 -- из таблицы task4
		ORDER BY created_at DESC -- отсортированного от нового к старому
		LIMIT 5 -- не более 5 записей
	) AS task_condition
) ORDER BY created_at DESC; -- сортируя от новых к старым

SELECT * FROM task4 ORDER BY created_at DESC; -- смотрим на результат
-- оно работает :)

-- =============================================================================================== --
-- Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)”  --
-- =============================================================================================== --

/* 1. Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read 
 * должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop. */

DROP USER IF EXISTS 'shop_read'@'localhost'; -- удаляем пользователя, если он уже есть
CREATE USER 'shop_read'@'localhost' IDENTIFIED BY 'Qwerty2'; -- создаём его со сложнейшим паролем
GRANT SELECT ON shop.* TO 'shop_read'@'localhost'; -- выдаём ему права на чтение любых таблиц в бд shop

DROP USER IF EXISTS 'shop'@'localhost'; -- удаляем пользователя shop, если он уже есть
CREATE USER 'shop'@'localhost' IDENTIFIED BY 'Qwerty123!'; -- создаём его с паролем посложнее, всё таки полные права
GRANT ALL PRIVILEGES ON shop.* TO 'shop'@'localhost'; -- выдаем ему картбланш на дебош

/* 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, 
 * имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
 * Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username. */

DROP TABLE IF EXISTS accounts; 
CREATE TABLE accounts ( -- создадим таблицу по условию задачи
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	password VARCHAR(255)
);

INSERT INTO accounts VALUES -- добавим туда нескольких пользователей
	(NULL, 'Ivan', 'Qwerty'),
	(NULL, 'Stepan', 'Qwerty2'),
	(NULL, 'Igor', 'Aezakmi12'),
	(NULL, 'Natasha', 'Hesoyam1!3'),
	(NULL, 'Vera', 'IDDQD'),
	(NULL, 'Katya', 'IDKFNA');

CREATE OR REPLACE VIEW username(user_id, user_name) AS -- создаём представление username по заданию
	SELECT id, name FROM shop.accounts;
	
DROP USER IF EXISTS 'user_read'@'localhost'; -- удаляем пользователя, если он уже есть
CREATE USER 'user_read'@'localhost' IDENTIFIED BY '1223334444'; -- создаем его заново с мегапаролем 1234
GRANT SELECT ON shop_online.username TO 'shop_reader'@'localhost'; -- выдаём ему права только на чтение представления username

-- ====================================================================== --
-- Практическое задание по теме “Хранимые процедуры и функции, триггеры”  --
-- ====================================================================== --

/* 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
 * С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 * с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи". */

-- Выполнил задание двумя способами
-- 1й способ - с использованием IF
DROP PROCEDURE IF EXISTS hello; -- удаляем процедуру, если она уже есть
delimiter // -- выставляем // в качестве "отделителя"
CREATE PROCEDURE hello() -- создаём процедуру
BEGIN
	IF(HOUR(CURTIME()) BETWEEN '6' AND '12') THEN -- если час текущего времени между 6 и 12
		SELECT 'Доброе утро'; -- выводим "Доброе утро"
	ELSEIF (HOUR(CURTIME()) BETWEEN '12' AND '18') THEN -- если час текущего времени между 12 и 18
		SELECT 'Добрый день'; -- выводим "Добрый день"
	ELSEIF (HOUR(CURTIME()) BETWEEN '18' AND '24') THEN -- если час текущего времени между 18 и 24
		SELECT 'Добрый вечер'; -- выводим "Добрый вечер"
	ELSE -- в ином случае, т.е. если час между 24 (00) и 6
		SELECT 'Доброй ночи'; -- выводим "Доброй ночи"
	END IF; -- завершаем блок IF
END // -- завершаем процедуру
delimiter ; -- возвращаем ; в качестве "отделителя"
 
CALL hello(); -- проверяем работу процедуры

-- 2й способ - с использованием CASE
DROP PROCEDURE IF EXISTS hello; -- удаляем процедуру, если она уже есть
delimiter // -- выставляем // в качестве "отделителя"
CREATE PROCEDURE hello() -- создаём процедуру
BEGIN
	CASE -- в случае
		WHEN HOUR(CURTIME()) BETWEEN '6' AND '12' THEN -- когда час текущего времени между 6 и 12
			SELECT 'Доброе утро'; -- выводим "Доброе утро"
		WHEN HOUR(CURTIME()) BETWEEN '12' AND '18' THEN -- когда час текущего времени между 12 и 18
			SELECT 'Добрый день'; -- выводим "Добрый день"
		WHEN HOUR(CURTIME()) BETWEEN '18' AND '24' THEN -- когда час текущего времени между 18 и 24
			SELECT 'Добрый вечер'; -- выводим "Добрый вечер"
		ELSE -- в любом другом случае
			SELECT 'Доброй ночи'; -- выводим "Доброй ночи"
	END CASE; -- завершаем блок CASE
END // -- завершаем процедуру
delimiter ; -- возвращаем ; в качестве "отделителя"

CALL hello(); -- проверяем работу процедуры

/* 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное 
 * значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
 * При попытке присвоить полям NULL-значение необходимо отменить операцию. */

DROP TRIGGER IF EXISTS nullTrigger; -- удаляем триггер, если он уже есть
delimiter // -- выбираем в качестве "отделителя" //
CREATE TRIGGER nullTrigger BEFORE INSERT ON products -- создаем триггер 
FOR EACH ROW
BEGIN
	IF(ISNULL(NEW.name) AND ISNULL(NEW.description)) THEN -- если в новой записи ОБА поля (name и description) не определены (NULL)
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trigger Warning! NULL in both fields!'; -- рушим выполнение запроса с ошибкой NULL in both fields 
	END IF; -- завершаем блок IF
END // -- завершаем триггер
delimiter ; -- возвращаем ; в качестве "отделителя"

-- Проверим работу триггера
INSERT INTO products (name, description, price, catalog_id)
VALUES (NULL, NULL, 5000, 2); -- сходу пробуем ввести два NULL, вылетает ошибка, это прекрасно, жмём SKIP чтоб посмотреть, отработает ли дальше

INSERT INTO products (name, description, price, catalog_id)
VALUES ("GeForce RTX 3080", NULL, 250000, 3); -- добавилась без ошибок

INSERT INTO products (name, description, price, catalog_id)
VALUES ("GeForce RTX 3080 Ti", "Стоит, как истребитель", 250000, 3); -- -- добавилась без ошибок

SELECT * FROM products; -- проверяем, что в итоге :)

/* 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
 * Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
 * Вызов функции FIBONACCI(10) должен возвращать число 55. */

-- Сделал корявенько, но оно работает)) немного костыльно выглядит решение с адекватным выводом 0го члена последовательности,
-- т.е. FIBONACCI(0). Но, т.к. задача "по-желанию", считаю, что достиг успешного успеха :D

DROP FUNCTION IF EXISTS `FIBONACCI`; -- удаляем функцию, если она уже есть
delimiter // -- выбираем // в качестве "отделителя"
CREATE FUNCTION `FIBONACCI`(n_number INTEGER(11)) -- создаем функцию
    RETURNS int(11)
    NO SQL -- без понятия, что это, но без этого вылетает ошибка, что нужен такой параметр :D
BEGIN
DECLARE i int default 1; -- объявляем локальную переменную i (счетчик). Ставим ему по умолчанию 1, чтобы адекватно считалось 0е число последовательности
set @f1:=1; -- i-2ое число последовательности
set @f2:=0; -- i-1ое число последовательности
set @f3:=0; -- i-ое число последовательности (искомое)
WHILE i <= n_number DO -- пока счётчик не достигнет заданного числа
	set @f3:=@f1+@f2; -- считаем i-ое значение
    set @f1:=@f2;	-- перемещаем i-1 на место i-2
    set @f2:=@f3;	-- перемещаем i на место i-1
    SET i =  i + 1; -- увеличиваем счётчик на единицу
END WHILE; -- завершение блока WHILE
RETURN @f3; -- возвращаем значение n_number-ого элемента последовательности
END// -- завершаем функцию
delimiter ; -- возвращаем ; в качестве "отделителя"

SELECT FIBONACCI(10); -- проверяем работу фунцкции


