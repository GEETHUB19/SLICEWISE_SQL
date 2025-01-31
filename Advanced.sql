-- Advanced:
-- 1.Calculate the percentage contribution of each pizza type to total revenue.
-- 2.Analyze the cumulative revenue generated over time.
-- 3.Determine the top 3 most ordered pizza types based on revenue for EACH pizza category.
-- 4.Generate a report showing the total sales for each day, including the date and total revenue.
-- 5.Find orders where a customer has ordered more than one pizza with different types in a single order.
-- 6.Calculate the average number of pizzas per order.
-- 7.Display orders that contain pizzas of multiple categories (e.g., Vegetarian and Non-Vegetarian in the same order or eg: Chicken and Veggie in same order).
-- 8.Write a query to display all pizza types that have never been ordered.
-- 9.List orders that only contain pizzas above a certain price threshold (e.g., only pizzas costing more than $10).
-- 10.Create a query to find out which pizza size has generated the most revenue.

-- use the line below for executing the control in the database
use PizzaHut;

-- 1.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS type_sales
	FROM order_details JOIN pizzas 
    ON order_details.pizza_id = pizzas.pizza_id) * 100,2) AS Percentage_Distribution
FROM order_details JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- 2.
-- cumulative means increasing
-- eg: 		 cumulative
-- 	day1 200 200
-- 	day2 400 600(200+400)
--  day3 300 900(600+300)...

select date,sum(revenue) over(order by date) as cumulative_revenue
from
(select orders.date,
sum(order_details.quantity*pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as Sales;


-- 3.
select category,type_name,revenue_for_this_type,
rank() over(partition by category order by revenue_for_this_type desc) as rn
from
(select pizza_types.category,pizza_types.type_name,sum(order_details.quantity * pizzas.price) as revenue_for_this_type
from order_details join pizzas 
on order_details.pizza_id =pizzas.pizza_id
join pizza_types on 
pizza_types.pizza_type_id= pizzas.pizza_type_id
group by pizza_types.category,pizza_types.type_name) as a ;
-- now we only need the record of those pizzas where rank = 1,2,3 but we cant directly apply where here because rn cannot be found 
-- hence making this another sub query

select category,type_name, revenue_for_this_type,rn from
(select category,type_name,revenue_for_this_type,
rank() over(partition by category order by revenue_for_this_type desc) as rn
from
(select pizza_types.category,pizza_types.type_name,sum(order_details.quantity * pizzas.price) as revenue_for_this_type
from order_details join pizzas 
on order_details.pizza_id =pizzas.pizza_id
join pizza_types on 
pizza_types.pizza_type_id= pizzas.pizza_type_id
group by pizza_types.category,pizza_types.type_name) as a) as b 
where rn=1 or rn=2 or rn=3 ;

-- 4.
SELECT 
    orders.date AS Date,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Date
ORDER BY Date;

-- 5.-use of having clause in this question because we need to check the distinctiveness of pizzas AFTER grouping the order_ids

SELECT 
    od.order_id AS O_ID
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY O_ID
HAVING COUNT(DISTINCT p.pizza_type_id) > 1;

-- 6.
SELECT 
    AVG(Quantity_per_order) AS Avg_quantity_per_order
FROM
    (SELECT 
        od.order_id, SUM(od.quantity) AS Quantity_per_order
    FROM
        order_details od
    GROUP BY od.order_id) AS Total_pizzas;
    
-- 7.(use of IN)
SELECT od.order_id
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
JOIN orders o ON od.order_id = o.order_id
WHERE pt.category IN ('Chicken', 'Veggie')
GROUP BY od.order_id
HAVING COUNT(DISTINCT pt.category) = 2
ORDER BY od.order_id;

-- 8.-0 rows returned because no pizza type like that exists(use of "NOT IN" and "IS")
select pt.type_name as P_Name
from pizza_types pt
where pt.pizza_type_id not in
(select p.pizza_type_id from order_details od
join pizzas p on p.pizza_id=od.pizza_id);

-- OR: in the above solution we check if the pizza type id exists in the ids ordered in the order table which is very simple
-- but in the solution below we see if a pizza type id has an order id -"null" which would mean that this type hasnt been ordered by anyone
select pt.type_name 
from pizza_types pt
join pizzas p on p.pizza_type_id=pt.pizza_type_id
join order_details od on od.pizza_id =p.pizza_id
where order_id is NULL;

-- 9.
select od.order_id from order_details od
join pizzas p on p.pizza_id =od.pizza_id
group by od.order_id
having min(p.price) > 10;

-- 10.
select p.size as Size, round(sum(p.price*od.quantity),2) as HighestTotalRevenue
from pizzas p join order_details od
on od.pizza_id = p.pizza_id
group by Size
order by HighestTotalRevenue desc
limit 1;


