-- Basic:
-- 1.Retrieve the total number of orders placed.
-- 2.Calculate the total revenue generated from pizza sales.
-- 3.Identify the highest-priced pizza.
-- 4.Identify the most commonly ordered quantity.
-- 5.Identify the most common pizza size ordered.
-- 6.List the top 5 most ordered pizza types along with their quantities.
-- 7.Count how many distinct orders of each type have been ordered so far.
-- 8.Count how many pizzas(quantity of pizzas, that is one order can have 3 pizzas so adding all of it) of each category have been ordered so far.
-- 9.Find the total quantity of pizzas ordered in each order
-- 10.How many people ordered (number of disctinct orders) where the size is medium or large.

-- use the line below for executing the control in the database
use PizzaHut;s

-- 1.
SELECT 
    COUNT(order_id) AS Total_Orders_Placed
FROM
    orders;

-- 2.
SELECT 
    ROUND(SUM(price * quantity), 2) AS Total_Revenue
FROM
    pizzas,
    order_details
WHERE
    pizzas.pizza_id = order_details.pizza_id;
-- OR
-- select
-- sum(order_details.quantity * pizzas.price) as Total_Revenue
-- from order_details join pizzas
-- on pizzas.pizza_id = order_details.pizza_id


-- 3.
SELECT 
    pizza_types.type_name, pizzas.price as Max_Price
FROM
    pizzas,
    pizza_types
WHERE
    pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4.
SELECT 
    quantity AS Ordered_Quantity,
    COUNT(order_details_id) AS Number_Of_Orders
FROM
    order_details
GROUP BY quantity;

-- 5.
-- whenever count is used, group by has to be used
SELECT 
    size AS Available_Sizes,
    COUNT(order_details_id) AS Number_Of_Orders
FROM
    pizzas,
    order_details
WHERE
    pizzas.pizza_id = order_details.pizza_id
GROUP BY size;

-- 6.
-- At first i had written :

-- select pizza_types.type_name as Name_Of_Pizza, sum(order_details.quantity) as Quantity_Ordered
-- from pizza_types join pizzas
-- on pizza_types.pizza_type_id = pizzas.pizza_type_id
-- join order_details
-- on pizzas.pizza_id = order_details.pizza_id
-- group by pizza_types.type_name order by order_details.quantity desc limit 5;

-- This was wrong because MySQL's ONLY_FULL_GROUP_BY SQL mode, which enforces stricter grouping rules. 
-- In your query, you're using an ORDER BY clause with a non-aggregated column (order_details.quantity) 
-- that is not part of the GROUP BY clause. When ONLY_FULL_GROUP_BY is enabled, MySQL requires that all columns 
-- in the SELECT or ORDER BY clauses either be aggregated (like SUM()) or be part of the GROUP BY clause.
-- To fix the error, you should modify the ORDER BY clause to use the aggregated column (SUM(order_details.quantity))
--  instead of the non-aggregated order_details.quantity.
--  
-- That is, the total or aggregated quantity or with the usage of sum() should be used with full group than the 
-- before aggregated indivisual column of order_details.quantity


SELECT 
    pizza_types.type_name AS Name_Of_Pizza,
    SUM(order_details.quantity) AS Quantity_Ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.type_name
ORDER BY Quantity_Ordered DESC
LIMIT 5;
 
 
-- 7.
select pizza_types.type_name,count(order_id)as no_of_order
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.type_name;

-- 8.
select pizza_types.category, sum(order_details.quantity) as quantity_ordered
from pizzas join order_details
on pizzas.pizza_id= order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category;

-- 9.
select order_id,count(quantity) as pizzas_in_this_order
from order_details 
group by order_id;

-- 10.
-- sum query for total orders of sizes M and L
SELECT 
    SUM(Orders_leaving_SXLXXL) AS Only_ML_Orders
FROM
    (SELECT 
        COUNT(order_details.order_id) AS Orders_leaving_SXLXXL,
            pizzas.size
    FROM
        order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    WHERE
        pizzas.size = 'L' OR pizzas.size = 'M'
    GROUP BY pizzas.size) AS total;

-- subquery inside of individual order quantity for M and L
select count(order_details.order_id)as Only_ML_Orders,pizzas.size 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
where pizzas.size = "L" or pizzas.size = "M"
group by pizzas.size;