# PizzaMax Database Analysis

## Introduction
PizzaMax is a database designed to analyze various aspects of a pizza business, including orders, revenues, popular pizza types, and sales trends. This repository provides SQL queries to retrieve insights from the database, covering basic, intermediate, and advanced levels of analysis.

---

## Database Schema

### 1. Database Creation
```sql
CREATE DATABASE pizzamax;
USE pizzamax;
```

### 2. Tables

#### a) `orders`
```sql
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
```

#### b) `order_details`
```sql
CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);
```

---

## SQL Queries

### **Basic Queries**
1. **Retrieve the total number of orders placed**
   ```sql
   SELECT 
    COUNT(order_id) AS total_orders
   FROM
    orders;
   ```

2. **Calculate the total revenue generated from pizza sales**
   ```sql
   SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
   FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
   ```

3. **Identify the highest-priced pizza**
   ```sql
   SELECT 
    pizza_types.name, pizzas.price
   FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
   ORDER BY pizzas.price DESC
   LIMIT 1;
   ```

4. **Identify the most common pizza size ordered**
   ```sql
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
   ```

5. **Top 5 most ordered pizza types along with their quantities**
   ```sql
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
   ```

### **Intermediate Queries**
6. **Total quantity of each pizza category ordered**
   ```sql
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
   ```

7. **Distribution of orders by hour of the day**
   ```sql
   SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
   FROM
    orders
   GROUP BY 1;
   ```

8. **Category-wise distribution of pizzas**
   ```sql
   SELECT 
    category, COUNT(name)
   FROM
    pizza_types
   GROUP BY 1
   ORDER BY 2 DESC;
   ```

9. **Average number of pizzas ordered per day**
   ```sql
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
   ```

10. **Top 3 most ordered pizza types based on revenue**
    ```sql
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
    ```

### **Advanced Queries**

11. **Percentage contribution of each pizza type to total revenue**
    ```sql
    SELECT pizza_types.category, 
           ROUND(SUM(order_details.quantity * pizzas.price) / 
           (SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) 
            FROM order_details 
            JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,     2) AS revenue
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY 1
    ORDER BY 2 DESC;
    ```

12. **Cumulative revenue generated over time**
    ```sql
    SELECT order_date, 
           ROUND(SUM(revenue) OVER(ORDER BY order_date), 2) AS cum_revenue
    FROM (
        SELECT orders.order_date, 
               SUM(order_details.quantity * pizzas.price) AS revenue
        FROM order_details
        JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN orders ON orders.order_id = order_details.order_id
        GROUP BY 1
    ) AS sales;
    ```

13. **Top 3 most ordered pizza types based on revenue for each category**
    ```sql
    SELECT name, revenue
    FROM (
        SELECT category, name, revenue, 
               RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS      rn
        FROM (
            SELECT pizza_types.category, pizza_types.name, 
                   SUM(order_details.quantity * pizzas.price) AS revenue
            FROM pizza_types
            JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
            JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
            GROUP BY 1, 2
        ) AS a
    ) AS b
    WHERE rn <= 3;
    ```

---

## Repository Highlights
1. **Well-structured queries**: Covers basic, intermediate, and advanced levels of SQL analysis.
2. **Database insights**: Includes revenue analysis, trends, and performance of pizza categories.
3. **Ready-to-use scripts**: Easily adaptable for other datasets.

---

## Contributions
Feel free to contribute by optimizing queries, adding new insights, or integrating with visualization tools.

---
