DROP DATABASE IF EXISTS restaurant;
CREATE DATABASE restaurant;
USE restaurant;
-- создаём таблицу с цехами

DROP TABLE IF EXISTS shops;
CREATE TABLE shops (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название цеха'
) COMMENT = 'Цеха ресторана';

-- заполняем таблицу с цехами

INSERT INTO shops VALUES
  (NULL, 'Холодный цех'),
  (NULL, 'Горячий цех'),
  (NULL, 'Мясо-рыбный цех'),
  (NULL, 'Кондитерский цех'),
  (NULL, 'Моечная');
  
 -- создаём таблицу со складами
DROP TABLE IF EXISTS warehouses;
CREATE TABLE warehouses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название склада'
) COMMENT = 'Складские помещения';

-- заполняем таблицу со складами

INSERT INTO warehouses VALUES
  (NULL, 'Охлаждаемый склад'),
  (NULL, 'Неохлаждаемый склад');
  
-- создаём таблицу с ингридиентами
DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название', 
  desription TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена за литр/кг',
  weight DECIMAL (10,3) COMMENT 'Вес',
  warehouse_id BIGINT UNSIGNED,
  CONSTRAINT fk_warehouse_id FOREIGN KEY (warehouse_id) REFERENCES warehouses (id),
  INDEX ingr_id_idx (id)
) COMMENT = 'Ингредиенты для блюд';

-- заполняем таблицу с ингредиентами

INSERT INTO ingredients VALUES
  (NULL, 'Молоко', 'Молоко 3.2%', 100, 20, 1),
  (NULL, 'Творог', 'Творог зернистый', 700, 15, 1),
  (NULL, 'Сахар', 'Сахар-песок', 70, 50, 2),
  (NULL, 'Гречка', 'Крупа гречневая', 150, 10, 2),
  (NULL, 'Макароны', 'Изделия макаронные', 200, 12, 2),
  (NULL, 'Говядина', 'Говядина (вырезка)', 1500, 10, 1),
  (NULL, 'Свинина', 'Свинина (шейка)', 1000, 15, 1),
  (NULL, 'Курица', 'Грудка куриная без кожи', 220, 12, 1),
  (NULL, 'Лук', 'Лук репчатый', 50, 10, 2),
  (NULL, 'Грибы', 'Грибы шампиньоны чищенные', 250, 11, 1),
  (NULL, 'Сметана', 'Сметана 20%', 350, 13, 1),
  (NULL, 'Сливки', 'Сливки 33%', 600, 18, 1),
  (NULL, 'Молоко', 'Молоко 3.2%', 100, 20, 1),
  (NULL, 'Масло сливочное', 'Масло сливочное 82%', 800, 8, 1),
  (NULL, 'Масло подсолнечное', 'Масло подсолнечное рафинированное', 110, 25, 2),
  (NULL, 'Масло оливковое', 'Масло оливковое прямого отжима', 1200, 17, 2),
  (NULL, 'Мука', 'Мука пшеничная высший сорт', 50, 42, 2),
  (NULL, 'Чеснок', 'Чеснок молодой зубчики', 330, 12, 2),
  (NULL, 'Соль', 'Соль поваренная пищевая', 14, 11, 2),
  (NULL, 'Креветки', 'Креветки очищенные варёно-мороженые', 1200, 8, 1),
  (NULL, 'Сыр', 'Сыр пармезан тёртый', 1260, 7, 1),
  (NULL, 'Укроп', 'Укроп свежий мытый', 56, 5, 1),
  (NULL, 'Петрушка', 'Петрушка свежая мытая', 400, 5, 1),
  (NULL, 'Кинза', 'Кинза свежая мытая', 700, 5, 1),
  (NULL, 'Салат', 'Салат айсберг свежий', 208, 5, 1),
  (NULL, 'Перец', 'Перец чёрный молотый', 100, 20, 2),
  (NULL, 'Томаты', 'Помидоры черри красные', 550, 10, 1),
  (NULL, 'Хлеб пшеничный', 'Хлеб белый в нарезке', 100, 7, 2),
  (NULL, 'Хлеб ржаной', 'Хлеб чёрный в нарезке', 300, 6, 2),
  (NULL, 'Яйца куриные', 'Яйца куриные категории С0', 100, 7, 1),
  (NULL, 'Яйца перепелиные', 'Яйца перепелиные', 376, 8, 1),
  (NULL, 'Майонез', 'Майонез классический', 200, 12, 1),
  (NULL, 'Горчица', 'Горчица средне-острая', 744, 6.5, 1),
  (NULL, 'Лимоны', 'Лимоны жёлтые', 160, 8, 1),
  (NULL, 'Вода', 'Вода питьевая', 30, 50, 1);
  
 -- создаем таблицу с блюдами
DROP TABLE IF EXISTS dishes;
CREATE TABLE dishes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название', 
  desription TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена за порцию',
  weight DECIMAL (10,3) COMMENT 'Вес порции (кг)',
  cal_content DECIMAL (5,2) COMMENT 'Калорийность порции',
  shop_id BIGINT UNSIGNED COMMENT 'Цех, в котором готовится',
  CONSTRAINT fk_shop_id FOREIGN KEY (shop_id) REFERENCES shops (id),
  INDEX dish_name_idx (name),
  UNIQUE INDEX dish_id_idx (id)
) COMMENT = 'Блюда в ресторане';

-- заполняем таблицу с блюдами

INSERT INTO dishes VALUES
  (NULL, 'Бефстроганов с говядиной', 'Популярное в России блюдо, названное в честь графа Александра Григорьевича Строганова. Готовится из мелко нарезанных кусочков говядины (тонкие квадратики), залитых горячим сметанным соусом.', 900, 0.272, 416.8, 2),
  (NULL, 'Паста с креветками', 'Паста с креветками в сливочно-чесночном соусе ', 700, 0.267, 285.8, 2),
  (NULL, 'Салат "Цезарь"', 'Салат "Цезарь" с курицей', 390, 0.15, 237.4, 1);
 
 -- создаём таблицу с рецептами
 
DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dish_id BIGINT UNSIGNED COMMENT 'ID блюда',
  ingred_id BIGINT UNSIGNED COMMENT 'ID ингредиента',
  ingred_weight DECIMAL (10,3) COMMENT 'Вес ингредиента для блюда',
  CONSTRAINT fk_dish_id FOREIGN KEY (dish_id) REFERENCES dishes (id),
  CONSTRAINT fk_ingred_id FOREIGN KEY (ingred_id) REFERENCES ingredients (id),
  INDEX rec_dish_id_idx (dish_id),
  INDEX rec_ingr_id_idx (ingred_id)
) COMMENT = 'Рецепты блюд';

-- заполняем таблицу с рецептами

INSERT INTO recipes VALUES
  (NULL, 1, 6, 0.6),
  (NULL, 1, 9, 0.15),
  (NULL, 1, 17, 0.025),
  (NULL, 1, 15, 0.01),
  (NULL, 1, 11, 0.2),
  (NULL, 1, 27, 0.06),
  (NULL, 1, 23, 0.04),
  (NULL, 1, 19, 0.001),
  (NULL, 1, 26, 0.001),
  (NULL, 2, 5, 0.25),
  (NULL, 2, 27, 0.095),
  (NULL, 2, 20, 0.4),
  (NULL, 2, 18, 0.016),
  (NULL, 2, 12, 0.2),
  (NULL, 2, 15, 0.02),
  (NULL, 2, 23, 0.02),
  (NULL, 2, 35, 0.6),
  (NULL, 3, 25, 0.05),
  (NULL, 3, 21, 0.05),
  (NULL, 3, 28, 0.05),
  (NULL, 3, 8, 0.3),
  (NULL, 3, 34, 0.05),
  (NULL, 3, 30, 0.055),
  (NULL, 3, 16, 0.02),
  (NULL, 3, 33, 0.014),
  (NULL, 3, 19, 0.005);
 
 -- создаём таблицу "официанты"
CREATE TABLE waiters (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(145) NOT NULL COMMENT 'Имя',
  middle_name VARCHAR(145) NOT NULL COMMENT 'Отчество',
  last_name VARCHAR(145) NOT NULL COMMENT 'Фамилия',
  gender ENUM('male', 'female'),
  phone CHAR(11) NOT NULL COMMENT 'Телефон',
  birthday DATE NOT NULL COMMENT 'Дата рождения',
  UNIQUE INDEX waiter_id_idx (id)
);

-- наполняем таблицу "официанты"
INSERT INTO waiters VALUES 
  (NULL, 'Петр', 'Степанович', 'Иванченко', 'male', '89212223334', '1980-02-03'),
  (NULL, 'Алиса', 'Владимировна', 'Высоцкая', 'female', '89991237645', '1994-03-05');
  
 -- создаем таблицу "зал"
 
DROP TABLE IF EXISTS guest_hall;
CREATE TABLE guest_hall (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- id столика
  seats INT COMMENT 'Количество мест за столиком',
  is_busy BOOL DEFAULT 0 COMMENT 'Признак занятости',
  is_smoking_area BOOL DEFAULT 0 COMMENT 'Признак зоны для курения',
  is_VIP BOOL DEFAULT 0 COMMENT 'Признак зоны для VIP-гостей',
  is_reserved BOOL DEFAULT 0 COMMENT 'Признак бронирования',
  waiter_id BIGINT UNSIGNED COMMENT 'id закреплённого официанта',
  CONSTRAINT fk_waiter_id FOREIGN KEY (waiter_id) REFERENCES waiters (id),
  UNIQUE INDEX gh_seat_id_idx (id),
  INDEX gh_waiter_id_idx (waiter_id)
) COMMENT = 'Описание столика';

-- наполняем таблицу "зал"

INSERT INTO guest_hall VALUES 
  (NULL, 2, DEFAULT, 1, DEFAULT, DEFAULT, 1),
  (NULL, 4, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 1),
  (NULL, 2, DEFAULT, 1, 1, 1, 2),
  (NULL, 3, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 1),
  (NULL, 4, DEFAULT, DEFAULT, 1, DEFAULT, 2);

 -- создаём таблицу "заказы"
 
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- id заказа
  seat_id BIGINT UNSIGNED COMMENT 'id столика',
  dish_id BIGINT UNSIGNED COMMENT 'id блюда',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'время принятния заказа',
  is_finished BOOL DEFAULT 0 COMMENT 'Признак выполненного заказа',
  CONSTRAINT fk_order_seat_id FOREIGN KEY (seat_id) REFERENCES guest_hall (id),
  CONSTRAINT fk_order_dish_id FOREIGN KEY (dish_id) REFERENCES dishes (id),
  INDEX order_seat_id_idx (seat_id)
) COMMENT = 'Описание заказа';

-- наполняем таблицу с заказами

INSERT INTO orders VALUES 
  (NULL, 2, 1, DEFAULT, DEFAULT),
  (NULL, 2, 3, DEFAULT, DEFAULT),
  (NULL, 5, 2, '2021-03-05 20:44:03', 1);
  
-- создаём таблицу с гостями

DROP TABLE IF EXISTS guests;
CREATE TABLE guests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(145) NOT NULL COMMENT 'Имя',
  middle_name VARCHAR(145) NOT NULL COMMENT 'Отчество',
  last_name VARCHAR(145) NOT NULL COMMENT 'Фамилия',
  gender ENUM('male', 'female'),
  phone CHAR(11) NOT NULL COMMENT 'Телефон',
  email VARCHAR(55) NOT NULL COMMENT 'e-mail',
  birthday DATE NOT NULL COMMENT 'Дата рождения',
  is_VIP BOOL DEFAULT 0 COMMENT 'Признак важного гостя',
  UNIQUE INDEX guest_id_idx (id)
);

-- наполняем таблицу с гостями
INSERT INTO guests VALUES 
  (NULL, 'Алексей', 'Владимирович', 'Молочкин', 'male', '89161234567', 'e@mail.com', '1973-02-10', DEFAULT),
  (NULL, 'Ирина', 'Федоровна', 'Бурушкина', 'female', '89622437587', 'i.buru@shkina.com', '1982-03-11', DEFAULT),
  (NULL, 'Владимир', 'Владимирович', 'Пушкин', 'male', '11111111111', 'bigboss@kremlin.ru', '1952-10-07', 1),
  (NULL, 'Инесса', 'Федоровна', 'Арманд', 'female', '89250031720', 'armand@example.com', '1953-12-10', DEFAULT),
  (NULL, 'Владимир', 'Михайлович', 'Гундяев', 'male', '77777777777', 'ingodwetrust@patriarchia.ru', '1946-11-20', 1);
  
-- создаем таблицу "reservation"
 
DROP TABLE IF EXISTS reservation;
CREATE TABLE reservation (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  seat_id BIGINT UNSIGNED COMMENT 'id столика',
  guest_id BIGINT UNSIGNED COMMENT 'id гостя',
  reserve_time DATETIME NOT NULL COMMENT 'время брони',
  CONSTRAINT fk_reserv_seat_id FOREIGN KEY (seat_id) REFERENCES guest_hall (id),
  CONSTRAINT fk_reserv_guest_id FOREIGN KEY (guest_id) REFERENCES guests (id)
  ) COMMENT = 'описание брони';

 -- наполнение таблицы "reservation"
INSERT INTO reservation VALUES 
  (NULL, 3, 3, '2021-05-09 09:00:00');

