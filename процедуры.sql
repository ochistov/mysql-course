USE restaurant;
-- Процедура, считающая, сколько блюд можно приготовить
-- из ингридиентов, находящихся на складе
DROP FUNCTION IF EXISTS `dishes_calc`;
delimiter // 
CREATE FUNCTION `dishes_calc`(dish_name VARCHAR(255)) 
    RETURNS INT(11)
    NO SQL
BEGIN
	DECLARE resultat INT;
	SELECT MIN(ingredients.weight DIV recipes.ingred_weight) INTO resultat
		FROM ingredients
		LEFT JOIN recipes
		ON recipes.ingred_id = ingredients.id
		LEFT JOIN dishes 
		ON dishes.id = recipes.dish_id
		WHERE LOWER(dishes.name) LIKE LOWER(CONCAT('%',dish_name,'%'));
RETURN resultat;
END//
delimiter ;

SELECT dishes_calc('цезарь')