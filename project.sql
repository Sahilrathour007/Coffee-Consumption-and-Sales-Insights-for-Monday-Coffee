USE monday_coffee;
-- Q! How many people in each city are estimated to consume coffee, given that 25% of the population does? 
SELECT city_name, 
	   ROUND((population * 0.25)/1000000, 2) AS Coffee_consumers_in_millions 
FROM city ORDER BY Coffee_consumers_in_millions DESC;

-- Q2 What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT 
  city.city_name, 
  SUM(sales.total) AS total_revenue
FROM sales 
JOIN customers ON customers.customer_id = sales.customer_id
JOIN city ON city.city_id = customers.city_id
WHERE sale_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY city.city_name;

-- Q3 How many units of each coffee product have been sold?
SELECT products.product_id,
		products.product_name,
		COUNT(sale_id)
AS order_count FROM sales
JOIN products ON products.product_id = sales.product_id
GROUP BY products.product_id, products.product_name ORDER BY order_count DESC;

-- Q4 What is the average sales amount per customer in each city?
SELECT city.city_name,
      ROUND(SUM(sales.total)/COUNT(DISTINCT customers.customer_name), 2) 
AS Average_sale_per_customer  FROM sales
JOIN customers ON customers.customer_id = sales.customer_id
JOIN city ON city.city_id = customers.city_id
GROUP BY city.city_name
ORDER BY Average_sale_per_customer DESC;

-- Q5 Provide a list of cities along with their populations and estimated coffee consumers.
SELECT 
  city.city_name, 
  city.population,
  ROUND((city.population * 0.25)/1000000, 2) AS estimated_coffee_customers_in_million, 
  COUNT(DISTINCT customers.customer_id) AS coffee_consumers
FROM sales
JOIN customers ON customers.customer_id = sales.customer_id
JOIN city ON city.city_id = customers.city_id
GROUP BY city.city_name, city.population
ORDER BY estimated_coffee_customers_in_million DESC;

-- Q6 What are the top 3 selling products in each city based on sales volume?
SELECT * FROM (
  SELECT 
    city.city_name, 
    products.product_name, 
    COUNT(sales.total) AS total_orders,
    DENSE_RANK() OVER (
      PARTITION BY city.city_name 
      ORDER BY COUNT(sales.total) DESC
    ) AS ranking
  FROM sales
  JOIN products ON products.product_id = sales.product_id
  JOIN customers ON customers.customer_id = sales.customer_id
  JOIN city ON city.city_id = customers.city_id
  GROUP BY city.city_name, products.product_name
) AS t1
WHERE ranking <= 3;

-- Q7 How many unique customers are there in each city who have purchased coffee products?
SELECT city.city_name, COUNT(DISTINCT customers.customer_id) AS unique_customers FROM sales 
JOIN customers ON customers.customer_id = sales.customer_id
JOIN city ON city.city_id = customers.city_id
JOIN products ON products.product_id = sales.product_id
WHERE sales.product_id <=14
GROUP BY city.city_name ORDER BY unique_customers DESC;

-- Q8 Find each city and their average sale per customer and avg rent per customer
SELECT 
  city.city_name, 
  ROUND(SUM(sales.total) / COUNT(DISTINCT sales.customer_id), 2) AS average_sale_per_customer,   
  ROUND(city.estimated_rent / COUNT(DISTINCT sales.customer_id), 2) AS average_rent_per_customer
FROM sales 
JOIN customers ON customers.customer_id = sales.customer_id
JOIN city ON city.city_id = customers.city_id
GROUP BY city.city_name, city.estimated_rent
ORDER BY average_sale_per_customer, average_rent_per_customer DESC;

-- Q9 Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH monthly_sales AS (
  SELECT 
    EXTRACT(MONTH FROM sale_date) AS sales_month, 
    SUM(total) AS monthly_sales
  FROM sales
  GROUP BY sales_month
)
SELECT 
  sales_month,
  monthly_sales,
  LAG(monthly_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
  ROUND(
    (monthly_sales - LAG(monthly_sales) OVER (ORDER BY sales_month)) 
    / LAG(monthly_sales) OVER (ORDER BY sales_month) * 100, 2
  ) AS growth_rate
FROM monthly_sales;

-- Q10 Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
SELECT 
  city.city_name,
  city.estimated_rent,
  COUNT(DISTINCT sales.customer_id) AS total_customers,
  SUM(sales.total) AS total_sales,
  ROUND(city.population * 0.25 / 1000000, 2) AS estimated_coffee_consumers
FROM sales
JOIN customers ON customers.customer_id = sales.customer_id
JOIN city ON city.city_id = customers.city_id
GROUP BY city.city_name, city.estimated_rent, city.population;
