/*Предполагаем, что у нас создана и заполнена из hw-5-data.sql база lesson5. Все задания выполняются в ней. */

/*------------------------------------------------------*/
-- «Операторы, фильтрация, сортировка и ограничение» --
/*------------------------------------------------------*/

/* 1 задание. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем. */
SELECT created_at, updated_at FROM users; -- убедимся, что поля пустые

UPDATE users -- изменям таблицу users
    SET created_at = NOW() WHERE created_at is NULL; -- меняем created_at на текущее время везде, где значение NULL
UPDATE users
	SET updated_at = NOW() WHERE updated_at IS NULL; -- то же самое для updated_at
	
SELECT created_at, updated_at FROM users; -- убедимся, что запрос отработал корректно
	
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
	
/* 2 задание. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и 
 * в них долгое время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения. */
DESCRIBE users; -- проверим тип данных полей created_at и updated_at. Действительно VARCHAR(255)
SELECT created_at, updated_at FROM users; -- проверим значения

UPDATE users SET
	created_at = str_to_date(created_at, "%d.%m.%Y %k:%i"), -- приводим значения к формату, в котором MySQL видит время
	updated_at = str_to_date(updated_at, "%d.%m.%Y %k:%i"); -- то же самое для updated_at

ALTER TABLE users MODIFY created_at DATETIME; -- меняем тип данных на DATETIME в created_at
ALTER TABLE users MODIFY updated_at DATETIME; -- то же самое для updated_at

DESCRIBE users; -- убедимся, что тип данных изменился на DATETIME
SELECT created_at, updated_at from users; -- убедимся, что значения сохранились

/*---------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 3 задание. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
 * 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
 * чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей. */
SELECT * FROM storehouses_products
  ORDER BY (CASE WHEN value = 0 THEN TRUE ELSE FALSE END), value; -- решение нашёл методом проб и ошибок, выражение в скобках перемещает value = 0 в конец

/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
  
/* 4 задание. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
 * Месяцы заданы в виде списка английских названий (may, august) */
  
/*Сделать получилось легко)) до этого сталкивался с запросом 
 * SELECT MONTHNAME(NOW());
 * который выводит текущий месяц в формате January, February, ..., December :D */
SELECT name, birthday_at FROM users WHERE MONTHNAME(birthday_at) IN ('may', 'august'); -- извлекаем из даты рождения месяц, сравниваем с may и august, при совпадении выводим)

/*---------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 5 задание. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
 * Отсортируйте записи в порядке, заданном в списке IN.
 */
/* Таблицу catalogs создал схемой из файла shop.sql в архиве source04.zip
 * Подозреваю, что где-то ошибся, как-то слишком просто для задания со * :D
 * почитал про ORDER BY, узнал, что можно сортировать с помощью FIELD(), указывая, какой столбец в каком порядке сортировать. */
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2); -- сортируем по полю id в порядке 5, 1, 2
-- SELECT* FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(name, 'Оперативная память', 'Процессоры', 'Материнские платы'); -- так тоже сработает))

/*------------------------------------------------------*/
-- «Операторы, фильтрация, сортировка и ограничение» --
/*------------------------------------------------------*/

/* 1 задание. Подсчитайте средний возраст пользователей в таблице users. */
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS average_age FROM users; -- вариант без округления до целых лет
SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())), 0) AS average_age FROM users; -- вариант с округлением

/* 2 задание. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
 * Следует учесть, что необходимы дни недели текущего года, а не года рождения. */

SELECT
	DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS week_day, -- DATE_FORMAT(YYYY-MM-DD, '%W') возвращает день недели от даты
	-- YEAR(NOW()) - меняем год рождения на текущий
	COUNT(*) AS week_day_quantity
FROM users
GROUP BY week_day -- группируем по дням недели
ORDER BY week_day_quantity DESC; -- сортируем по количеству, DESC чтобы сначала выводились наибольшие значения

/* 3 задание. (по желанию) Подсчитайте произведение чисел в столбце таблицы. */
-- Для начала создадим таблицу и наполним её числами
DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers(
id INT AUTO_INCREMENT PRIMARY KEY,
value FLOAT); -- FLOAT, а не INT, потому что числа бывают с дробной частью, а результат может получиться огромным :)

INSERT INTO numbers VALUES
    (DEFAULT, 1),
    (DEFAULT, 2),
    (DEFAULT, 3),
    (DEFAULT, 4),
    (DEFAULT, 5);
    
SELECT * FROM numbers; -- проверим, что таблица создана и заполнена

/* Так как в SQL нет функции, считающей произведение, а перемножать значения,
 * используя оператор "*" - глупо, потому что в текущей задаче их 5, а может быть
 * и 5000, и 50 000, придётся вспоминать курс матанализа из университета, который
 * подсказывает нам, что логарифм произведения равен сумме логарифмов. Сумму SQL умеет
 * считать функцией SUM(), а получить произведение из логарифма произведения можно, 
 * если в качестве логарифма мы будем использовать логарифм с основанием e (натуральный 
 * логарифм) - ln(), а потом просто возведём экспоненту в степень с использованием функции EXP()*/

SELECT EXP(SUM(ln(value))) AS product_of_numbers FROM numbers;
-- Получившийся результат совпал с ответом из задания :) Для себя попробовал с бОльшим количеством чисел (заполнял через filldb), считает правильно,
-- но можно добавить округление с использованием ROUND() :D


