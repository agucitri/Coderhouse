-- databse activation
USE proyectoCoder;


-- (1) view vw_orders_description
CREATE OR REPLACE VIEW vw_orders_description AS
SELECT
	od.id_order_details AS Id,
    od.id_order AS Order_num,
    od.quantity AS Quantity,
    o.date AS Date,
    p.price AS Sell_Price,
    SUM(od.quantity * p.price) AS Total,
    td.time_del_type AS Delivery_Type,
    ca.category AS Category,
    co.colour AS Colour,
    s.size AS Size,
    cu.custom_type AS Custom
FROM ORDERS AS o
JOIN ORDER_DETAILS AS od ON od.id_order = o.id_order
JOIN TIME_DELIVERY AS td ON td.id_time_del = o.id_time_del
JOIN PRODUCTS AS p ON p.id_product = od.id_product
JOIN PROD_CATEG AS ca ON ca.id_prod_categ = p.id_prod_categ
JOIN PROD_COLOUR AS co ON co.id_colour = p.id_colour
JOIN PROD_SIZE AS s ON s.id_size = p.id_size
JOIN CUSTOMIZATIONS AS cu ON cu.id_custom = od.id_custom
GROUP BY od.id_order_details, od.id_order
ORDER BY od.id_order_details ASC;

SELECT * FROM vw_orders_description
LIMIT 5;


-- (2) view vw_customer_orders
CREATE OR REPLACE VIEW vw_customer_orders AS
SELECT
	cu.id_customer AS Id_Customer,
    cu.first_name AS Name,
    cu.last_name AS Last_name,
    TIMESTAMPDIFF(YEAR, cu.birthday, CURDATE()) AS Age,
    COUNT(o.id_order) AS Q_Orders
FROM ORDERS AS o
JOIN CUSTOMERS AS cu ON cu.id_customer = o.id_customer
GROUP BY cu.id_customer
ORDER BY COUNT(o.id_order) DESC;

SELECT * FROM vw_customer_orders
LIMIT 5;


-- (3) view vw_branch_incomes_orders
CREATE OR REPLACE VIEW vw_branch_incomes_orders AS
SELECT
	br.id_branch AS Id,
	br.name_branch AS Branch,
    br.br_province AS Province,
    SUM(od.quantity * p.price) AS Incomes,
    ROUND((SUM(od.quantity * p.price) / 
		(SELECT SUM(od.quantity * p.price) FROM ORDER_DETAILS od 
		 JOIN PRODUCTS AS p ON p.id_product = od.id_product)) * 100, 2) AS Perc_incomes_over_total,
	COUNT(DISTINCT od.id_order) AS Q_Orders,
    ROUND((COUNT(DISTINCT od.id_order) / (SELECT COUNT(*) FROM ORDERS)) * 100, 2) AS Perc_orders_over_total
FROM ORDER_DETAILS AS od
JOIN PRODUCTS AS p ON p.id_product = od.id_product
JOIN ORDERS AS o ON o.id_order = od.id_order
JOIN BRANCHS AS br ON br.id_branch = o.id_branch
GROUP BY br.id_branch
ORDER BY SUM(od.quantity * p.price) DESC;

SELECT * FROM vw_branch_incomes_orders
LIMIT 5;


-- (4) view vw_product_performance
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    ca.category AS Category,
    co.colour AS Colour,
    SUM(od.quantity) AS Quantity,
    SUM(od.quantity * p.price) AS Income,
    ROUND((SUM(od.quantity * p.price) / 
		(SELECT SUM(od.quantity * p.price) FROM ORDER_DETAILS od 
		 JOIN PRODUCTS AS p ON p.id_product = od.id_product)) * 100, 2) AS Perc_incomes_over_total
FROM ORDER_DETAILS AS od
JOIN PRODUCTS AS p ON p.id_product = od.id_product
JOIN PROD_CATEG AS ca ON ca.id_prod_categ = p.id_prod_categ
JOIN PROD_COLOUR AS co ON co.id_colour = p.id_colour
GROUP BY ca.category, co.colour
ORDER BY SUM(od.quantity) DESC;

SELECT * FROM vw_product_performance
LIMIT 5;


-- (5) view vw_customer_gasto_acum
CREATE OR REPLACE VIEW vw_customer_gasto_acum AS
SELECT
	o.id_customer AS Id_Customer,
    cu.first_name AS Name,
    cu.last_name AS Last_name,
    DATE(MAX(o.date)) AS Last_Order,
    SUM(od.quantity * p.price) AS Total_Spent,
	ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT o.id_order), 1) AS Avg_per_order
FROM ORDER_DETAILS AS od
JOIN ORDERS AS o ON o.id_order = od.id_order
JOIN CUSTOMERS AS cu ON cu.id_customer = o.id_customer
JOIN PRODUCTS AS p ON p.id_product = od.id_product
GROUP BY cu.id_customer
ORDER BY SUM(od.quantity * p.price) DESC;

SELECT * FROM vw_customer_gasto_acum
LIMIT 5;


