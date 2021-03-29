/*БД у себя создал этим скриптом, вопросов по его работе и структуре нет:)
 * пока что предложений по усовершенствованию нет, но я еще подумаю, возможно,
 * появятся к следующему ДЗ.
 * 
 * --------------------------------------------------------------------------------------------
 * 
 * По поводу курсового проекта - я решил попробовать сделать базу данных для сети
 * ресторанов. В качестве таблиц могут быть блюда (с которыми связаны таблицы с их стоимостью,
 * ингридиентами, из которых они готовятся, стоимостью ингридиентов). Также может быть таблица
 * с номерами столиков, с которой, в свою очередь, связана таблица с персоналом (какой официант 
 * обслуживает какой столик). Помимо вышеупомянутых, можно добавить таблицу цехов (холодный цех,
 * салатный, горячий цех, печь для пиццы и т.п.), которая, в свою очередь связана с остальными
 * таблицами. Также планирую добавить учет гостей, таблицу скидок, в т.ч. накопительные скидки,
 * скидки на День рождения, акции, скидки постоянным клиентам и пр. 
 * В целом, должно получиться больше 10 таблиц, почти все они будут связаны друг с другом и, на
 * мой субъективный взгляд, это несколько интереснее, чем делать шаблонный интернет-магазин или
 * пытаться клонировать википедию в качестве курсовой :)
 * Было бы очень интересно выслушать Ваше мнение на этот счет, это пока просто мысли, если Вы 
 * одобрите, буду потихоньку приступать:)
 * 
 * -------------------------------------------------------------------------------------------- 
 * 
 *
 * А теперь к выполнению домашней работы) Я решил взять скрипт прямо из Вашего занятия и просто
 * в него дописывать новые таблицы. Для Вашего удобства я удалил все многострочные комментарии,
 * чтобы Вам было проще ориентироваться. Все свои действия старался оформлять комментариями
 * и пояснениями.
 */
DROP DATABASE IF EXISTS vk;

CREATE DATABASE vk;

USE vk;

SHOW tables;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(145) NOT NULL, -- COMMENT "Имя",
  last_name VARCHAR(145) NOT NULL,
  email VARCHAR(145) NOT NULL,
  phone CHAR(11) NOT NULL,
  password_hash CHAR(65) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- NOW()
  UNIQUE INDEX email_unique_idx (email),
  UNIQUE INDEX phone_unique_idx (phone)
) ENGINE=InnoDB;

-- Заполним таблицу, добавим Петю и Васю
INSERT INTO users VALUES (DEFAULT, 'Petya', 'Petukhov', 'petya@mail.com', '89212223334', DEFAULT, DEFAULT);
INSERT INTO users VALUES (DEFAULT, 'Vasya', 'Vasilkov', 'vasya@mail.com', '89212023334', DEFAULT, DEFAULT);

CREATE TABLE profiles (
  user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  gender ENUM('f', 'm', 'x') NOT NULL, -- CHAR(1)
  birthday DATE NOT NULL,
  photo_id INT UNSIGNED,
  user_status VARCHAR(30),
  city VARCHAR(130),
  country VARCHAR(130),
  CONSTRAINT fk_profiles_users FOREIGN KEY (user_id) REFERENCES users (id) -- ON DELETE CASCADE ON UPDATE CASCADE
);

DESCRIBE profiles;

-- Заполним таблицу, добавим профили для уже созданных Пети и Васи
INSERT INTO profiles VALUES (1, 'm', '1997-12-01', NULL, NULL, 'Moscow', 'Russia'); -- профиль Пети
INSERT INTO profiles VALUES (2, 'm', '1988-11-02', NULL, NULL, 'Moscow', 'Russia'); -- профиль Васи


CREATE TABLE messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  txt TEXT NOT NULL, -- txt = ПРИВЕТ
  is_delivered BOOLEAN DEFAULT False,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- NOW()
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  INDEX fk_messages_from_user_idx (from_user_id),
  INDEX fk_messages_to_user_idx (to_user_id),
  CONSTRAINT fk_messages_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_messages_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);

DESCRIBE messages;

-- Добавим два сообщения от Пети к Васе, одно сообщение от Васи к Пете
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Hi!', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 1
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Vasya!', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2
INSERT INTO messages VALUES (DEFAULT, 2, 1, 'Hi, Petya', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2


CREATE TABLE friend_requests (
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  accepted BOOLEAN DEFAULT False,
  PRIMARY KEY(from_user_id, to_user_id),
  INDEX fk_friend_requests_from_user_idx (from_user_id),
  INDEX fk_friend_requests_to_user_idx (to_user_id),
  CONSTRAINT fk_friend_requests_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_friend_requests_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);

-- Добавим запрос на дружбу от Пети к Васе
INSERT INTO friend_requests VALUES (1, 2, 1);

CREATE TABLE communities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(145) NOT NULL,
  description VARCHAR(245) DEFAULT NULL,
  admin_id BIGINT UNSIGNED NOT NULL,
  INDEX communities_users_admin_idx (admin_id),
  CONSTRAINT fk_communities_users FOREIGN KEY (admin_id) REFERENCES users (id)
) ENGINE=InnoDB;

-- Добавим сообщество с создателем Петей
INSERT INTO communities VALUES (DEFAULT, 'Number1', 'I am number one', 1);

SELECT * FROM communities;

-- Таблица связи пользователей и сообществ
CREATE TABLE communities_users (
  community_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
  PRIMARY KEY (community_id, user_id),
  INDEX communities_users_comm_idx (community_id),
  INDEX communities_users_users_idx (user_id),
  CONSTRAINT fk_communities_users_comm FOREIGN KEY (community_id) REFERENCES communities (id),
  CONSTRAINT fk_communities_users_users FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB;

-- Добавим запись вида Вася участник сообщества Number 1
INSERT INTO communities_users VALUES (1, 2, DEFAULT);

CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(45) NOT NULL UNIQUE -- изображение, музыка, документ
) ENGINE=InnoDB;

-- Добавим типы в каталог
INSERT INTO media_types VALUES (DEFAULT, 'изображение');
INSERT INTO media_types VALUES (DEFAULT, 'музыка');
INSERT INTO media_types VALUES (DEFAULT, 'документ');

CREATE TABLE media (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Картинка 1
  user_id BIGINT UNSIGNED NOT NULL,
  media_types_id INT UNSIGNED NOT NULL, -- фото
  file_name VARCHAR(245) DEFAULT NULL COMMENT '/files/folder/img.png',
  file_size BIGINT UNSIGNED,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX media_media_types_idx (media_types_id),
  INDEX media_users_idx (user_id),
  CONSTRAINT fk_media_media_types FOREIGN KEY (media_types_id) REFERENCES media_types (id),
  CONSTRAINT fk_media_users FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Добавим два изображения, которые добавил Петя
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im.jpg', 100, DEFAULT);
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im1.png', 78, DEFAULT);
-- Добавим документ, который добавил Вася
INSERT INTO media VALUES (DEFAULT, 2, 3, 'doc.docx', 1024, DEFAULT);


/* Первая таблица, добавляемая в ходе выполнения практического задания - посты пользователя
 * Смысл таблицы - хранить посты, опубликованные на "стене" (или это уже давно "микроблог"?:)
 * я просто в основном телегой пользуюсь, давно отстал от жизни)) но сути это не меняет)
 * Логика - должно храниться текстовое содержание поста, к этому посту может быть прикреплен
 * медиафайл (но по умолчанию медиафайла нет). Соответственно, хранит информацию об id пользователя,
 * текстовом содержании поста, прикрепленном медиафайле (в случае его наличия)
 */

CREATE TABLE wall_publication (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- собственно, id поста
  user_id BIGINT UNSIGNED NOT NULL, -- id пользователя, на чьей "стене" размещен пост
  media_id BIGINT UNSIGNED DEFAULT NULL, -- id вложения (по умолчанию вложений нет)
  content VARCHAR(255) DEFAULT "Empty post", -- содержание поста (у нас как в твиттере, 255 символов :D
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- учтем время добавления поста (вдруг пригодится)
  PRIMARY KEY(id, user_id), -- добавим в primary key и id самого поста, и id пользователя, его добавившего
  INDEX content_idx (content), -- добавление индексирования по тексту поста (например, чтоб удобнее искать экстимистсткие высказывания
  INDEX created_at_idx (created_at), -- я решил добавить индекс и сюда - вдруг Вася решит поискать, что же он постил в 2007м
  CONSTRAINT fk_wallpub_users FOREIGN KEY (user_id) REFERENCES users (id), -- связь с таблицей, содержащей пользователей
  CONSTRAINT fk_wallpub_media FOREIGN KEY (media_id) REFERENCES media (id) -- связь с таблицей, содержащей медиафайлы
);

-- Добавим Пете на стену пост с глубокомысленным философским текстом, но без контента
INSERT INTO wall_publication VALUES (DEFAULT, 1, DEFAULT, "Не плюй в колодец, вылетит - не поймаешь", DEFAULT);
-- Добавим Васе на стену пост с прикрепленным документом doc.docx
INSERT INTO wall_publication VALUES (DEFAULT, 2, 3, "Это вовсе не фанфик про BTS", DEFAULT);

-- Посмотрим, что у нас получилось
SELECT * FROM wall_publication; -- получилось, вроде, неплохо :)

/* В качестве следующей таблицы добавим черный список, в который наши пользователи смогут
 * добавлять различных злодеев, чтобы они не донимали их назойливой рекламой и прочими
 * радостями злодейской жизни.
 * Логика - по аналогии с friend_request содержит информацию, кто из пользователей кого
 * добавил в черный список.
 */
 
CREATE TABLE black_list (
  from_user_id BIGINT UNSIGNED NOT NULL, -- id пользователя, добавляющего в черный список
  to_user_id BIGINT UNSIGNED NOT NULL, -- id пользователя, добавляемого в черный список
  reason_why VARCHAR(255) DEFAULT NULL, -- не уверен, что такое есть вк, но комментарий, за что пользователь был "блэклистнут"
  PRIMARY KEY(from_user_id, to_user_id),
  INDEX reason_why_idx (reason_why), -- индексируем поиск по причине добавления в чс, на случай, если забудутся старые обиды
  CONSTRAINT fk_black_list_user_1 FOREIGN KEY (from_user_id) REFERENCES users (id), -- связь с таблицей, содержащей пользователей
  CONSTRAINT fk_black_list_user_2 FOREIGN KEY (to_user_id) REFERENCES users (id) -- связь с таблицей, содержащей пользователей
);

-- Предположим, что Пете не понравился пост, который опубликовал Вася, и он решил добавить его в черный список
INSERT INTO black_list VALUES (1, 2, "Ненавижу кей-поп");

-- Проверим, что из этого вышло
SELECT * FROM black_list; -- и снова сработало :)

/* Следующим шагом добавим таблицу с постами в сообществах.
 * Таблица будет по аналогии с постами на "стене" содержать id автора поста, содержание поста (контент), также предусмотрена возможность
 * прикреплять к посту медиафайлы (однако, по умолчанию посты будут без них). Однако, в отличие от поста на стене, будет использоваться 
 * еще и id сообщества, в котором опубликован пост
 */

CREATE TABLE community_publication (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, -- id поста
  user_id BIGINT UNSIGNED NOT NULL, -- id пользователя, опубликовавшего пост
  media_id BIGINT UNSIGNED DEFAULT NULL, -- id медиафайла, прикрепленного к посту (по-умолчанию медиафайл отсутствует)
  community_id BIGINT UNSIGNED NOT NULL, -- id сообщества, в котором опубликован пост
  content VARCHAR(255) DEFAULT "Empty post", -- текстовое наполнение поста
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- дата публикации поста
  PRIMARY KEY(id, user_id, community_id),
  INDEX user_id_idx (user_id), -- индексация id пользователя, опубликовавшего пост
  INDEX community_id_idx (community_id), -- индексация id сообщества, в котором опубликован пост
  CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id), -- связь с таблицей users
  CONSTRAINT fk_media_id FOREIGN KEY (media_id) REFERENCES media (id), -- связь с таблицей media
  CONSTRAINT fk_community_id FOREIGN KEY (community_id) REFERENCES communities (id) -- связь с таблицей communities
);

/* Предположим, что Вася узнал, что Петя добавил его в черный список из-за сомнительных постов на стене и решил,
 * что единственный способ заслужить прощение - опубликовать в сообществе, администратором которого является Петя,
 * пост с извинениями и картинкой с милым котенком (все, ну или почти все, любят милых котят)
 */
INSERT INTO community_publication VALUES (DEFAULT, 2, DEFAULT, 1, "Ты что, заблочил меня?", DEFAULT);
INSERT INTO community_publication VALUES (DEFAULT, 2, 1, 1, "Прости меня, Петя! Я удалю эту гадость, честно", DEFAULT);

-- Проверим результат
SELECT * FROM community_publication; -- и снова сработало :)

/* На этом выполнение практического задания к 3 уроку (второму вебинару) завершено, три таблицы добавлены к БД vk,
 * а о дальнейшей судьбе взаимоотношений двух друзей мы узнаем при выполнении следующих заданий. Спасибо за внимание! :D
 */

