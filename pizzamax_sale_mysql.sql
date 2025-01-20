create database pizzamax;

use pizzamax;
create table orders
(
	order_id int not null,
    order_date date not null,
    order_time time not null,
    primary key (order_id)
);

select * from pizzamax.orders;

create table order_details(
	order_details_id int not null,
    order_id int not null,
    pizza_id text not null,
    quantity int not null,
    primary key (order_details_id)
);

select * from pizzamax.order_details;

-- Basic:

-- Q1. Retrieve the total number of orders placed.
select count(order_id) as total_orders
from orders;

-- Q2. Calculate the total revenue generated from pizza sales.
-- (revenue = quantity x price)

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- Q3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Q4. Identify the most common pizza size ordered.

-- (how many quantity how mnay times ordered)
SELECT 
    quantity, COUNT(order_details_id)
FROM
    order_details
GROUP BY quantity;

--
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quatities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Intermediate:

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
 
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Q7. Determine the distribution of orders by hour of the day.

select hour(order_time) as hours, count(order_id) as order_count
from orders
group by 1;



-- Q8. Join relevant tables to find the category-wise distribution of pizzas.
 
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY 1
ORDER BY 2 DESC;


-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity_pizza_per_day)) AS order_pizza_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS quantity_pizza_per_day
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY 1) AS order_quantity; 

-- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;



-- Advanced:

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Q12.Analyze the cumulative revenue generated over time.

select order_date,
round(sum(revenue) over(order by order_date), 2) as cum_revenue
from
(
select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by 1
) as sales;

-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue
from
(
select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(
select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from  pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by 1, 2) as a) as b
where rn <= 3;
