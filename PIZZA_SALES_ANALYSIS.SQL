CREATE DATABASE PIZZA_HUT;

USE PIZZA_HUT;

CREATE TABLE ORDER_DETAILS (
order_details_id INT PRIMARY KEY,
order_id INT,
pizza_id VARCHAR (50),
quantity INT,
FOREIGN KEY (order_id) REFERENCES ORDERS (order_id),
FOREIGN KEY (pizza_id) REFERENCES PIZZAS (pizza_id)
);

CREATE TABLE ORDERS (
order_id INT PRIMARY KEY,
date DATE,
time TIME
);

CREATE TABLE PIZZA_TYPES (
pizza_type_id VARCHAR(50) PRIMARY KEY,
name VARCHAR(50),
category VARCHAR(50),
ingredients VARCHAR(100)
);

CREATE TABLE PIZZAS (
pizza_id VARCHAR (50) PRIMARY KEY,
pizza_type_id VARCHAR(50),
size VARCHAR(50),
price DECIMAL(10,3),
FOREIGN KEY (pizza_type_id) REFERENCES PIZZA_TYPES (pizza_type_id)
);

SELECT * FROM ORDER_DETAILS;
SELECT * FROM ORDERS;
SELECT * FROM PIZZA_TYPES;
SELECT * FROM PIZZAS;

SELECT COUNT(*) FROM PIZZA_TYPES;

SET SESSION sql_mode = ''

load data  infile 
'D:/manish/Python/ineuron/PROJECTS/SQL/PIZZA/pizza_sales/pizza_sales/order_details.csv'
into table ORDER_DETAILS 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; 

load data  infile 
'D:/manish/Python/ineuron/PROJECTS/SQL/PIZZA/pizza_sales/pizza_sales/orders.csv'
into table ORDERS 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; 

load data  infile 
'D:/manish/Python/ineuron/PROJECTS/SQL/PIZZA/pizza_sales/pizza_sales/pizza_types.csv'
into table PIZZA_TYPES 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; 

load data  infile 
'D:/manish/Python/ineuron/PROJECTS/SQL/PIZZA/pizza_sales/pizza_sales/pizzas.csv'
into table PIZZAS 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; 

SET FOREIGN_KEY_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 1;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(OD.QUANTITY * P.PRICE), 2) AS TOTAL_REVENUE
FROM ORDER_DETAILS OD JOIN PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID;
    
-- Identify the highest-priced pizza

SELECT PT.name, MAX(P.price)
FROM PIZZAS P JOIN PIZZA_TYPES PT ON P.pizza_type_id = PT.pizza_type_id
GROUP BY PT.name
ORDER BY MAX(P.price) DESC
LIMIT 1

-- Identify the most common pizza size ordered.
SELECT P.size, COUNT(OD.QUANTITY) AS TOTAL_ORDERS
FROM PIZZAS P JOIN ORDER_DETAILS OD
ON P.pizza_id = OD.pizza_id
GROUP BY P.size ORDER BY TOTAL_ORDERS DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT PT.name, SUM(OD.QUANTITY) AS QUANTITY
FROM ORDER_DETAILS OD JOIN PIZZAS P ON  P.pizza_id = OD.pizza_id
JOIN PIZZA_TYPES PT ON P.pizza_type_id = PT.pizza_type_id
GROUP BY PT.name ORDER BY QUANTITY DESC LIMIT 5;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_DISTRIBUTION
FROM ORDERS GROUP BY HOUR(TIME)

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(pizza_type_id) AS PIZZA_TYPE
FROM PIZZA_TYPES 
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(avg (ORDERS_PLACED),0) AS AVG_NUMBER_PIZZAS
FROM
(SELECT O.DATE, SUM(OD.QUANTITY) AS ORDERS_PLACED
FROM ORDERS O JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY O.DATE) AS DATE_WISE_ORDERS;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT PT.NAME, SUM(OD.QUANTITY * P.PRICE) AS TOTAL_PRICE
 FROM ORDER_DETAILS OD JOIN PIZZAS P ON  P.pizza_id = OD.pizza_id
JOIN PIZZA_TYPES PT ON P.pizza_type_id = PT.pizza_type_id
GROUP BY PT.NAME ORDER BY TOTAL_PRICE DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT PT.category, ROUND(SUM(OD.QUANTITY * P.PRICE) / (SELECT ROUND(SUM(OD.QUANTITY * P.PRICE), 2) AS TOTAL_REVENUE
FROM ORDER_DETAILS OD JOIN PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID) *100,2 ) AS REVENUE
FROM PIZZA_TYPES PT JOIN PIZZAS P ON PT.pizza_type_id = P.pizza_type_id
JOIN ORDER_DETAILS OD ON OD.pizza_id = P.pizza_id
GROUP BY PT.category ORDER BY REVENUE DESC;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT DATE, SUM(REVENUE) OVER( ORDER BY DATE) AS CUM_REVENUE FROM
(SELECT O.DATE, SUM(OD.QUANTITY * P.PRICE) AS REVENUE
FROM ORDER_DETAILS OD JOIN PIZZAS P ON OD.pizza_id = P.pizza_id
JOIN ORDERS O ON O.ORDER_ID = OD.ORDER_ID
GROUP BY O.DATE) AS SALES;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT NAME, REVENUE FROM
(SELECT category, NAME, REVENUE,
RANK() OVER(PARTITION BY category ORDER BY REVENUE DESC) AS RN
FROM
(SELECT PT.category, PT.NAME,
SUM((OD.QUANTITY) * P.PRICE) AS REVENUE
FROM PIZZA_TYPES PT JOIN PIZZAS P ON PT.pizza_type_id = P.pizza_type_id
JOIN ORDER_DETAILS OD ON OD.pizza_id = P.pizza_id
GROUP BY PT.category, PT.NAME) AS A) AS B
WHERE RN <=3;




