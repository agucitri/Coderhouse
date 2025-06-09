-- databse activation
USE proyectoCoder;


-- (1) trigger tr_prod_insert
DROP TRIGGER IF EXISTS tr_prod_insert;

DELIMITER $$
CREATE TRIGGER tr_prod_insert
AFTER INSERT ON PRODUCTS
FOR EACH ROW
BEGIN
	INSERT INTO PROD_INSERTS_AUDIT (id_product, price, id_size, id_colour, id_prod_categ, user_log, date_insert, description)
    VALUES
		(NEW.id_product, NEW.price, NEW.id_size, NEW.id_colour, NEW.id_prod_categ, USER(), NOW(), 'ALTA');
END
$$
DELIMITER ;

-- insertamos nuevo valor en PROD_SIZE debido a la restriccion de la FK
INSERT INTO PROD_SIZE (size)
VALUES
	(43);

-- insertamos nuevo valor en PRODUCTS para comprobar si se registro la insercion en la tabla PROD_INSERTS_AUDIT
INSERT INTO PRODUCTS (stock, price, id_size, id_colour, id_prod_categ)
VALUES
	(34, 56000.00, 5, 1, 1);

-- comprobamos tabla PROD_INSERTS_AUDIT
SELECT * FROM PROD_INSERTS_AUDIT;



-- (2) trigger tr_new_customer
DROP TRIGGER IF EXISTS tr_new_customer;

DELIMITER $$
CREATE TRIGGER tr_new_customer
AFTER INSERT ON CUSTOMERS
FOR EACH ROW
BEGIN
	INSERT INTO NEW_CUSTOMER_AUDIT (id_customer, first_name, last_name, edad, date_insert, description)
    VALUES
		(NEW.id_customer, NEW.first_name, NEW.last_name, TIMESTAMPDIFF(YEAR, NEW.birthday, CURDATE()), NOW(), 'ALTA');
END
$$
DELIMITER ;

-- insertamos un nuevo cliente en CUSTOMERS para accionar el trigger
INSERT INTO CUSTOMERS (first_name, last_name, birthday, email)
VALUES
	('Agustin', 'Suarez', '1998-04-16', 'asuarez0@dot.eu.ch');

-- comprobamos si se registro del dato correctamente
SELECT * FROM NEW_CUSTOMER_AUDIT;



