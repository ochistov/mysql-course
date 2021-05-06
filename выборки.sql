USE restaurant;
-- Выборка массы ингредиентов для изготовления @n порций Бефстроганова (в граммах)
-- Также выводится остаток продуктов на складе после приготовления блюда
SET @n := 7;
SELECT
	ingredients.name AS ingred_name,
	(recipes.ingred_weight * 1000 * @n) AS ingred_weight_g,
	((ingredients.weight * 1000) - (recipes.ingred_weight * 1000 * @n)) AS will_lost_in_wh 
FROM (dishes
	LEFT JOIN recipes
	ON dishes.id = recipes.dish_id
	LEFT JOIN ingredients
	ON ingredients.id = recipes.ingred_id)
WHERE dishes.name LIKE 'Бефстроганов%'
ORDER BY dishes.id;

-- Выборка гостей, забронировавших столик
-- В выборку входят ФИО гостя, ИО официанта, № столика и время брони
-- JOIN чтобы не выводить NULL значения

SELECT 
	CONCAT_WS(' ', guests.first_name, guests.middle_name, guests.last_name) AS guest,
	guest_hall.id AS seat,
	(SELECT CONCAT_WS(' ', waiters.first_name, waiters.last_name)
		FROM waiters
		WHERE waiters.id = guest_hall.waiter_id) AS waiter,
	reservation.reserve_time AS time 
FROM (guests 
	JOIN reservation
	ON reservation.guest_id = guests.id)
	JOIN guest_hall
	ON guest_hall.id = reservation.seat_id
ORDER BY guests.id;

-- Выборка, считающая, сколько столов закреплено за каждым из официантов

SELECT
	(SELECT 
		CONCAT_WS(' ', waiters.first_name, waiters.last_name)
		FROM waiters
		WHERE waiters.id = guest_hall.waiter_id) AS waiter,
	COUNT(*) AS count
FROM guest_hall
GROUP BY waiter
ORDER BY waiter;
	