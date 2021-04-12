/* 1. Пусть задан некоторый пользователь. Найдите человека, который больше всех общался 
с нашим пользователем, иначе, кто написал пользователю 
наибольшее число сообщений. (можете взять пользователя с любым id). */
-- Выберем пользователя c id 6
SELECT COUNT(*) AS count, 
	(SELECT CONCAT(first_name, " ", last_name) FROM users WHERE id = messages.from_user_id) AS name -- Находим имя в таблице users
	FROM messages 
	WHERE to_user_id = 6 -- проверяем, чтобы сообщения были написаны конкретно нашему пользователю (id 6)
	GROUP BY from_user_id -- группируем по id отправителя
	ORDER BY count DESC -- сортируем по убыванию
	LIMIT 1; -- выводим только верхний (максимальный) результат

-- (по желанию: можете найти друга, с которым пользователь больше всего общался)
SELECT COUNT(*) AS friend_message_count,
	(SELECT CONCAT(first_name, " ", last_name) FROM users WHERE id = messages.from_user_id) AS name -- Находим имя в таблице users
	FROM messages
	WHERE to_user_id = 6 -- добавляем к условию, что получатель имеет id 6
	AND from_user_id IN  -- условие, что получатель принял запрос в друзья от отправителя сообщения
		(SELECT from_user_id FROM friend_requests 
		WHERE (to_user_id = 6 AND request_type = 1)
		UNION 
		SELECT from_user_id FROM friend_requests 
		WHERE from_user_id = 6 AND request_type = 1)	
	GROUP BY from_user_id -- группируем по id отправителя
	ORDER BY friend_message_count DESC -- сортируем по убыванию 
	LIMIT 1; -- выводим только верхний (максимальный) результат
-- Есть огромное подозрение, что можно было сделать проще, но голова отказывается соображать после работы :D
	
/* 2. Подсчитать общее количество лайков на посты, которые получили пользователи младше 18 лет. */
SELECT COUNT(*) AS count
	FROM posts_likes -- выбираем из таблицы post_likes
	WHERE (post_id IN -- только те посты, id которых входит в выборку
		(SELECT id FROM posts WHERE 
			user_id IN (SELECT user_id FROM profiles 
				WHERE (TIMESTAMPDIFF(YEAR, birthday, NOW())) < 18))) -- в профиле автора поста разница текущей даты с датой рождения меньше 18 лет
	AND like_type = 1; -- и лайк не отозван
-- Насколько я понимаю, скобки необязательны, но так, по моему мнению, проще понимать происходящее
	
/* 3. Определить, кто больше поставил лайков (всего) - мужчины или женщины? */
SELECT CASE -- выбираем по условию
	WHEN (SELECT @count_man := COUNT(*) -- присваеваем переменной count_man значение
		FROM posts_likes WHERE post_id IN ( -- из post_likes выбираем посты, которым
			SELECT id FROM posts WHERE user_id IN ( -- поставили лайки пользователи, у которых
				SELECT user_id FROM profiles WHERE ( -- в таблице profiles 
					gender IN ('m')))) -- пол 'm' - мужчины
			AND like_type = 1) -- и лайк не отозван
			>	-- больше, чем значение	
	(SELECT @count_woman := COUNT(*) -- присваеваем переменной count_woman значение
		FROM posts_likes WHERE post_id IN ( -- из post_likes выбираем посты, которым
			SELECT id FROM posts WHERE user_id IN ( -- поставили лайки пользователи, у которых
				SELECT user_id FROM profiles WHERE ( -- в таблице profiles 
					gender IN ('f')))) -- пол 'f' - женщины
			AND like_type = 1)  -- и лайк не отозван
		THEN 'Мужчины поставили больше лайков' -- если условие соблюдено, выводим результат
	WHEN @count_woman > @count_man -- если количество лайков, поставленных женщинами больше, чем мужчинами
		THEN 'Женщины поставили больше лайков' -- выводим другой результат
	ELSE 'Число лайков от женщин и мужчин одинаково' -- на случай, если число лайков совпадет
	END AS likes_count 
	FROM posts_likes
	GROUP BY likes_count; -- выводим только один ответ
-- Есть подозрение, что эту задачу тоже можно решить элегантнее, но так тоже работает, и работает неплохо :)

/* 4. (по желанию) Найти пользователя, который проявляет наименьшую активность в использовании 
социальной сети (тот, кто написал меньше всего сообщений, отправил меньше всего заявок в друзья, ...). */
SELECT 
	(SELECT concat(first_name, " ", last_name) FROM users WHERE id = user_id) AS Name FROM -- преобразуем user_id в имя с фамилией
	(SELECT * FROM	
		(SELECT user_id, count(*) AS posts_count -- считаем количество постов каждого пользователя
		FROM posts
		GROUP BY user_id) AS posts
	LEFT JOIN 			-- присоединяем количество запросов в друзья
		(SELECT from_user_id AS user_id, count(*) AS fr_req_count 
		FROM friend_requests
		GROUP BY from_user_id) AS friends
	USING(user_id)
	LEFT JOIN 			-- присоединяем количество лайков
		(SELECT user_id, count(*) AS likes_count 
		FROM posts_likes 
		GROUP BY user_id) AS likes
	USING(user_id)
	LEFT JOIN 			-- присоединяем количество медиа
		(SELECT user_id, count(*) AS media_count
		FROM media
		GROUP BY user_id) AS media
	USING(user_id)
	LEFT JOIN			-- присоединяем количество сообщений
		(SELECT from_user_id AS user_id, count(*) AS msg_count
		FROM messages 
		GROUP BY user_id) AS messages
	USING(user_id)
	LEFT JOIN			-- присоединяем кол-во сообществ, членом которых является юзверь
		(SELECT user_id, count(*) AS mem_comm_count
		FROM communities_users 
		GROUP BY user_id) AS member_communities
	USING(user_id)
	ORDER BY posts_count + fr_req_count + likes_count + media_count + msg_count + mem_comm_count) AS lower_act -- сортируем по сумме активностей
LIMIT 1; -- выводим только 1 имя пользователя - с наименьшим количеством активности 
-- получилось коряво и немного громоздко, но оно работает :)