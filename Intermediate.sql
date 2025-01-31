
-- Intermediate:
-- 1.Join the necessary tables to find the total quantity of each pizza category ordered.
-- 2.Determine the distribution of orders by hour of the day.
-- 3.Join relevant tables to find the category-wise distribution of pizzas.
-- 4.Group the orders by date and calculate the average number of pizzas ordered per day.
-- 5.Determine the top 3 most ordered pizza types based on revenue.
-- 6.Find the total amount spent on each order by summing the price of all pizzas in that order.
-- 7.Display the order IDs for orders where more than 3 pizzas were ordered.
-- 8.Show the date and quantity of orders for each in an interval of specified days.
-- 9.Find the average price of pizzas based on their size (e.g., small, medium, large).
-- 10.Identify the customers who have ordered more than a specified number of pizzas across all their orders and display their details along with the total quantity of pizzas ordered.


-- use the line below for executing the control in the database
use PizzaHut;

-- 1.
SELECT 
    SUM(order_details.quantity) AS Quantity_Ordered,
    pizza_types.category AS Category
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity_Ordered DESC;

-- 2.
SELECT 
    HOUR(time) AS Hour, COUNT(order_id) AS Number_of_Orders
FROM
    orders
GROUP BY HOUR(time);

-- 3.
SELECT 
    category, COUNT(type_name) AS Number_of_Pizzas
FROM
    pizza_types
GROUP BY category;

-- 4.
-- this gives sum of quanitity ordered everyday 
select date as Day , sum(quantity) as Everyday_Quantity
from orders,order_details
where orders.order_id=order_details.order_id
group by Day;
-- to further find average quantity alter
SELECT 
    ROUND(AVG(Everyday_Quantity), 0) AS Average_Quantity
FROM
    (SELECT 
        date AS Day, SUM(quantity) AS Everyday_Quantity
    FROM
        orders, order_details
    WHERE
        orders.order_id = order_details.order_id
    GROUP BY Day) AS Derived_SubQuery_Alias;
-- Derived_SubQuery_Alias- this name or alias had to be given because every derived table or sub query table should have its own alias or name

-- 5.
SELECT 
    pizza_types.type_name,
    SUM(order_details.quantity * pizzas.price) AS Revenue_of_this_pizza
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.type_name
ORDER BY Revenue_of_this_pizza DESC
LIMIT 3;

-- 6.
SELECT 
    order_details.order_id AS ID,
    SUM(order_details.quantity * pizzas.price) AS Money_Spent
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY order_details.order_id
ORDER BY order_details.order_id;

-- 7.
SELECT 
    ID, Quantity
FROM
    (SELECT 
        ID, Quantity
    FROM
        (SELECT 
        order_details.order_id AS ID,
            COUNT(order_details.quantity) AS Quantity
    FROM
        order_details
    GROUP BY order_id) AS table1) AS table2
WHERE
    Quantity >= 3;

-- 8.

SET @startDate = '2015-01-01';  -- Set your start date
SET @endDate = '2015-01-08';     -- Set your end date
SELECT
       No_of_orders, 
       Date
from
		(select sum(od.quantity) as No_of_orders, o.date as Date 
		from order_details od 
		join orders o on od.order_id = o.order_id
		group by Date) as table1
WHERE Date BETWEEN @startDate AND @endDate;

-- if we need to find number of orders in a specific number of past days eg.7 starting from today or the current date , use the line:
-- WHERE o.date >= CURDATE() - INTERVAL 30 DAY;

-- CURDATE() is a MySQL function that returns the current date (in the format YYYY-MM-DD), with no time component.
-- It essentially gives you "today’s date."

-- INTERVAL 7 DAY:
-- This expression subtracts an interval of 7 days from the current date (CURDATE()).

-- So the full condition o.date >= CURDATE() - INTERVAL 7 DAY will return all rows from the orders table 
-- where the order date is on or after(which is why '>=') the date 7 days ago.

-- 9.
SELECT 
    p.size AS Size,
    SUM(p.price) / COUNT(p.price) AS Average_Price
FROM
    pizzas p
GROUP BY Size;

-- 10.
SELECT 
    od.order_id AS ID, SUM(od.quantity) AS Quantity
FROM
    order_details od
GROUP BY od.order_id
HAVING SUM(Quantity) > 20;
