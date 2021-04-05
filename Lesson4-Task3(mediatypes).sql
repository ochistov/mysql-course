/* На случай непредвиденной ошибки данные из fillDB я залил в новую базу vk1
 * и именно её я использую для изменения таблицы media_types
 */

USE vk1; -- собственно, выбираю базу данных для работы
SELECT * FROM media_types; -- смотрим, как называются типы медиа. FillDB сгенерировал нам просто случайные слова
UPDATE media_types -- обновляем содержимое таблицы 
	SET name = CASE id --                           чтобы не писать одинаковые строки UPDATE, я решил поступить элегантнее
					WHEN 1 THEN 'image' --          и, воспользовавшись советом мудрых людей
					WHEN 2 THEN 'video' --          со stackoverflow,
					WHEN 3 THEN 'document' --       я сделал изменение значения поля name в зависимости от id
					WHEN 4 THEN 'gif_animation' --  и, соответственно, одним update заменил все значения.
				END 
 WHERE id BETWEEN 1 AND 4;
 
SELECT * FROM media_types; -- проверяем, что получилось на выходе

/* Получилось неплохо) долго думал, что добавить 4м типом,
 * в итоге добавил гиф анимации, так как они являются чем-то средним между
 * фото и видео и, насколько я знаю, в соцсетях они весьма популярны 
 */

