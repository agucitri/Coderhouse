-- databse activation
USE proyectoCoder;
 

-- (1) function f_ventas_prod_categ
DROP FUNCTION IF EXISTS f_ventas_prod_categ;

DELIMITER $$
CREATE FUNCTION f_ventas_prod_categ (p_id_prod_categ INT)
RETURNS DECIMAL (12, 2)
DETERMINISTIC
BEGIN
	DECLARE monto DECIMAL (12, 2);
    
    SELECT SUM(od.quantity * p.price)
	INTO monto
    FROM ORDER_DETAILS AS od
    INNER JOIN PRODUCTS AS p USING (id_product)
    WHERE p.id_prod_categ = p_id_prod_categ;
    
    RETURN IFNULL(monto, 0.00);
END
$$
DELIMITER ;

SELECT category, f_ventas_prod_categ(id_prod_categ) AS total_ventas
FROM PROD_CATEG
ORDER BY total_ventas DESC;


-- (2) function f_customer_q_ventas
DROP FUNCTION IF EXISTS f_customer_q_ventas;

DELIMITER $$
CREATE FUNCTION f_customer_q_ventas (p_id_customer INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE cantidad INT;
    
    SELECT COUNT(id_order)
    INTO cantidad
    FROM ORDERS AS o
    INNER JOIN CUSTOMERS AS c USING (id_customer)
    WHERE c.id_customer = p_id_customer;
    
    RETURN IFNULL(cantidad, 0);
END
$$
DELIMITER ;

SELECT id_customer, first_name, last_name, f_customer_q_ventas(id_customer) AS compras_realizadas
FROM customers
ORDER BY compras_realizadas DESC
LIMIT 5;

