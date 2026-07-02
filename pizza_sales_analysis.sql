create database pizza_db;

show databases;

use pizza_db;

show tables;

describe order_details;
describe orders;
describe pizza_types;
describe pizzas;

--------------------------------------------------
-- Retrieve the total number of orders
-- ===========================================
-- Query 1: Total Number of Orders
-- ===========================================

SELECT COUNT(order_id) AS Total_Orders
FROM orders;
-----------------------------------------------
-- Calculate the total revenue generated
-- ===========================================
-- Query 2: Total Revenue
-- ===========================================
SELECT
ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_Revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id;
------------------------------------------------------------

-- Find the highest-priced pizza
-- ===========================================
-- Query 3: Highest Priced Pizza
-- ===========================================

SELECT
pizza_types.name,
pizzas.price
FROM pizzas
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-------------------------------------------------------

-- Find the most common pizza size ordered
-- ===========================================
-- Query 4: Most Common Pizza Size
-- ===========================================

SELECT
pizzas.size,
COUNT(order_details.order_details_id) AS Total_Orders
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Total_Orders DESC;
---------------------------------------------------------

-- Top 5 Most Ordered Pizza Types

-- ===========================================
-- Query 5: Top 5 Most Ordered Pizza Types
-- ===========================================

SELECT
    pizza_types.name,
    SUM(order_details.quantity) AS Total_Quantity
FROM order_details
JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_Quantity DESC
LIMIT 5;
----------------------------------------------------------------

-- Total Quantity Sold by Pizza Category

-- ===========================================
-- Query 6: Quantity Sold by Category
-- ===========================================

SELECT
    pizza_types.category,
    SUM(order_details.quantity) AS Total_Quantity
FROM order_details
JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity DESC;
---------------------------------------------------------

-- Distribution of Orders by Hour
-- ===========================================
-- Query 7: Orders by Hour
-- ===========================================

SELECT
    HOUR(order_time) AS Order_Hour,
    COUNT(order_id) AS Total_Orders
FROM orders
GROUP BY Order_Hour
ORDER BY Order_Hour;

-----------------------------------------------------------
-- Category-wise Revenue

-- ===========================================
-- Query 8: Revenue by Category
-- ===========================================

SELECT
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Revenue
FROM order_details
JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-----------------------------------------------------------

-- Average Number of Pizzas Ordered Per Day
-- ===========================================
-- Query 9: Average Daily Pizza Orders
-- ===========================================

SELECT
    ROUND(AVG(Daily_Total), 2) AS Average_Pizzas_Per_Day
FROM (
    SELECT
        orders.order_date,
        SUM(order_details.quantity) AS Daily_Total
    FROM orders
    JOIN order_details
        ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS DailyOrders;

-------------------------------------------------------------

-- Determine the Top 3 Pizza Types Based on Revenue
-- ===========================================
-- Query 10: Top 3 Pizza Types by Revenue
-- ===========================================

SELECT
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Revenue
FROM order_details
JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

----------------------------------------------------------

-- Percentage Contribution of Each Pizza Category to Total Revenue
-- ===========================================
-- Query 11: Percentage Contribution of Each Pizza Category
-- ===========================================

SELECT
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Revenue,
    ROUND(
        (SUM(order_details.quantity * pizzas.price) /
        (SELECT SUM(order_details.quantity * pizzas.price)
         FROM order_details
         JOIN pizzas
         ON order_details.pizza_id = pizzas.pizza_id)) * 100,
    2) AS Revenue_Percentage
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;
---------------------------------------------------------------------

-- Cumulative Revenue Generated Over Time

-- ===========================================
-- Query 12: Cumulative Revenue Over Time
-- ===========================================

SELECT
    order_date,
    Daily_Revenue,
    SUM(Daily_Revenue) OVER (ORDER BY order_date) AS Cumulative_Revenue
FROM
(
    SELECT
        orders.order_date,
        ROUND(SUM(order_details.quantity * pizzas.price),2) AS Daily_Revenue
    FROM orders
    JOIN order_details
        ON orders.order_id = order_details.order_id
    JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY orders.order_date
) AS DailySales;
----------------------------------------------------------------------

-- Top 3 Pizza Types by Revenue for Each Category

-- ===========================================
-- Query 13: Top 3 Pizza Types by Revenue
-- For Each Pizza Category
-- ===========================================

SELECT *
FROM
(
    SELECT
        pizza_types.category,
        pizza_types.name,
        ROUND(SUM(order_details.quantity * pizzas.price),2) AS Revenue,
        RANK() OVER
        (
            PARTITION BY pizza_types.category
            ORDER BY SUM(order_details.quantity * pizzas.price) DESC
        ) AS Ranking
    FROM order_details
    JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types
        ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    GROUP BY
        pizza_types.category,
        pizza_types.name
) Ranked_Pizzas
WHERE Ranking <= 3;
