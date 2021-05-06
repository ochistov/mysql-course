USE restaurant;
-- Представление, показывающее, какие продукты хранятся на каком из складов
CREATE OR REPLACE VIEW ingredients_stored(name, warehouse) AS 
	SELECT ingredients.name, warehouses.name 
	FROM ingredients
	LEFT JOIN warehouses
	ON warehouses.id = ingredients.warehouse_id
	ORDER BY warehouses.name, ingredients.name;
SELECT * FROM ingredients_stored;

-- Представление, показывающее, сколько ингредиентов (в кг) осталось на складах
CREATE OR REPLACE VIEW ingredients_balance(name, weight_kg) AS 
	SELECT ingredients.name, ingredients.weight
	FROM ingredients
	ORDER BY ingredients.name;
SELECT * FROM ingredients_balance;