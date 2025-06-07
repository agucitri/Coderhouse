-- databse activation
USE proyectoCoder;


-- (1) store procedure generate_order
DROP PROCEDURE IF EXISTS generate_order;
/*
el SP genera el ingreso de un nuevo pedido u orden, haciendo ROLLBACK si ocurre algun error
durante al creacion de la orden
*/
DELIMITER $$
CREATE PROCEDURE generate_order(
	IN p_id_customer INT,
    IN p_date DATETIME,
    IN p_id_branch INT,
    IN p_id_time_del INT,
    OUT p_new_id INT
)
BEGIN
	-- manejo de errores
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
        /*
        en este caso se asigna RESIGNAL para que ante la presencia de un error, quien este ejecuntando
        el SP pueda visualizar que hubo un error y que la orden no fue insertada en la tabla
        */
    END;
    
    START TRANSACTION;
    /*
    se realiza dentro de una TRANSACTION ya que, como el SP add_order_detail (a continuacion de este SP)
    depende de esta SP generate_order, debemos asegurarnos de que este SP se ejecute correctamente
    */
    INSERT INTO ORDERS (id_customer, date, id_branch, id_time_del)
	VALUES
		(p_id_customer, p_date, p_id_branch, p_id_time_del);
	SET p_new_id = LAST_INSERT_ID();
    
    COMMIT;
END
$$
DELIMITER ;


-- (2) store procedure add_order_detail
DROP PROCEDURE IF EXISTS add_order_detail;
/*
el SP agrega una linea en la tabla ORDER_DETAILS luego de que se haya insertado
una nueva orden en ORDERS, insertando una linea por cada producto distinto en la orden
*/
DELIMITER $$
CREATE PROCEDURE add_order_detail(
	IN p_id_order INT,
    IN p_id_product INT,
    IN p_quantity INT,
    IN p_id_custom INT
)
BEGIN
	DECLARE v_stock INT;
    -- manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;

    SELECT stock
    INTO v_stock
    FROM PRODUCTS
    WHERE id_product = p_id_product
    FOR UPDATE; -- aca nos aseguramos que se bloquee el stock leido antes de que se llame a otro SP para otra orden
    
	IF v_stock < p_quantity THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Stock insuficiente';
	END IF;
    
    INSERT INTO ORDER_DETAILS (id_order, id_product, quantity, id_custom)
    VALUES
		(p_id_order, p_id_product, p_quantity, p_id_custom);
	
    -- actualizamos stock en la tabla PRODUCTS
    UPDATE PRODUCTS
    SET stock = stock - p_quantity
    WHERE id_product = p_id_product;
END
$$
DELIMITER ;

select * from customers;

/*
insertamos una nueva orden para corroborar que ambos SP funcionan como se esperaba
*/
START TRANSACTION;
CALL generate_order(210, NOW(), 3, 1, @new_id_order);
CALL add_order_detail(@new_id_order, 16, 2, 1);
CALL add_order_detail(@new_id_order, 37, 1, 3);

ROLLBACK;
COMMIT;



