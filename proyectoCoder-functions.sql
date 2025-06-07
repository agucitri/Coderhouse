-- databse activation
USE proyectoCoder;
 

-- (1) function q_ventas_prod_categ
DROP FUNCTION IF EXISTS ventas_prod_categ;

DELIMITER $$
CREATE FUNCTION ventas_prod_categ (p_id_prod_categ INT)
RETURNS DECIMAL (12, 2)
DETERMINISTIC
BEGIN
	DECLARE monto DECIMAL (12, 2);
    
    SELECT SUM(od.quantity * p.price)
	INTO monto
    FROM order_details od
    INNER JOIN products p USING (id_product)
    WHERE p.id_prod_categ = p_id_prod_categ;
    
    RETURN IFNULL(monto, 0.00);
END
$$
DELIMITER ;

SELECT category, ventas_prod_categ(id_prod_categ) AS total_ventas
FROM prod_categ
ORDER BY total_ventas DESC;


-- (2) function customer_q_ventas
DROP FUNCTION IF EXISTS customer_q_ventas;

DELIMITER $$
CREATE FUNCTION customer_q_ventas (p_id_customer INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE cantidad INT;
    
    SELECT COUNT(id_order)
    INTO cantidad
    FROM orders o
    INNER JOIN customers c USING (id_customer)
    WHERE c.id_customer = p_id_customer;
    
    RETURN IFNULL(cantidad, 0);
END
$$
DELIMITER ;

SELECT id_customer, first_name, last_name, customer_q_ventas(id_customer) AS compras_realizadas
FROM customers
ORDER BY compras_realizadas DESC;

