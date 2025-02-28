use Pizza_Sales;

--- Add Date_time column
ALTER Table orders add Time_of_day varchar(20)

UPDATE orders
SET Time_of_day = 
	(CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		ELSE 'Evening'
	END)
--------------------
ALTER TABLE ORDERS add Month_name varchar(20)
UPDATE orders 
SET Month_name =  month(date)
------------------
ALTER TABLE orders add Day_name varchar(5)
UPDATE orders
SET Day_name = Format (date, 'ddd')

-------------------- QUESTION -------------------
---1/ Retrieve the total number of orders placed
SELECT format(count(*),'N0') Number_Of_Order
FROM orders

---2/ Calcualte the total revenue generated from pizza sales
SELECT 
	format(sum((quantity * price)),'C') Total_Revenue
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id

---3/ Identify the highest-priced pizza
SELECT TOP 1 Name, * FROM pizzas as piz
JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id
ORDER BY price desc

---4/ Identify the most common pizza size ordered
SELECT 
	size, format(sum(quantity),'N0') Number_of_Size
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
GROUP BY size 
ORDER BY sum(quantity) desc

---5/ List the top 5 most ordered pizza types along with their quantities
SELECT TOP 5
	Name, format(sum(quantity),'N0') Quantity
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id 
JOIN pizza_types as pit ON pit.pizza_type_id = piz.pizza_type_id
GROUP BY name
ORDER BY sum(quantity) desc

---6/ Join the neccessary table to find the total quantity of each pizza category ordered
SELECT 
	Category, FORMAT(sum(quantity),'N0') Total_Quantity
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN pizza_types as pit ON pit.pizza_type_id = piz.pizza_type_id
GROUP BY category 
ORDER BY sum(quantity) desc



---7/ Determine the distribution of orders by hour of the day
SELECT DATETRUNC(HOUR,time) Hour, FORMAT(count(order_id),'N0') Number_of_Order 
FROM orders
GROUP BY DATETRUNC(hour,time)
ORDER BY Hour asc


---8/ Join relevant tables to find the category-wise distribution of pizzas
SELECT Name, category FROM pizzas as piz
JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id

---9/ Group the orders by date and calculate the average number of pizzas ordered per day
SELECT
	cast(avg(cast(total_Quantity as float)) as decimal(5,2)) Avg_Quantity_Per_Day	
FROM 
(SELECT 
	date, sum(quantity) Total_Quantity
FROM orders as ord
JOIN order_details as odt ON ord.order_id = odt.order_id
GROUP BY date) as Test1


---10/ Determine the top 3 most ordered pizza types based on revenue
SELECT TOP 3
	Name, FORMAT(sum( (quantity * price) ),'C') Revenue	
FROM order_details as odt
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id
GROUP BY name
ORDER BY sum((quantity * price)) desc;

---11/ Calculate the percentage contribution of each pizza type to total revenue
WITH table1 as 
(SELECT sum( (quantity * price) ) Total_Revenue
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id)
SELECT 
	Name, 
	FORMAT(SUM (quantity * price), 'C') Revenue,
	FORMAT((sum (quantity * price) / (SELECT Total_Revenue FROM table1 )), '#,#.00%') '% Contribution to total'
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id
GROUP BY name


---12/ Analyze the cumulative revenue generated over time
SELECT 
	Date, Revenue, FORMAT(running_total,'C') Running_Total
FROM 
(SELECT
	Date, FORMAT(Revenue, 'C') Revenue, sum(revenue) OVER (ORDER BY date asc) Running_Total
FROM
(SELECT date, sum((quantity * price)) Revenue
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN orders as ord ON ord.order_id = odt.order_id
GROUP BY date) as test1
GROUP BY date, Revenue) as test2


---13/ Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT Category, Name, Total_Revenue
FROM 
(SELECT
	Category, Name, Total_Revenue, rank() OVER (PARTITION BY Category ORDER BY Total_revenue desc) Rank
FROM
(SELECT 
	Category, Name, sum((quantity * price)) Total_Revenue
FROM order_details as odt
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN orders as ord ON ord.order_id = odt.order_id
JOIN pizza_types as pit ON pit.pizza_type_id = piz.pizza_type_id
GROUP BY category, name) as table1
) table2
WHERE Rank BETWEEN 1 AND 3 
