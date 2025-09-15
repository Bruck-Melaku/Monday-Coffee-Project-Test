-- 1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT *, ROUND((0.25 * population), 0) AS etimated_consumers
FROM city;

-- 2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT SUM(total) AS total_revenue
FROM sales
WHERE sale_date BETWEEN '2023-10-1' AND '2023-12-30';

-- 3. Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT s.product_id, p.product_name, COUNT(s.sale_id) units_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 3 DESC;

-- 4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?
SELECT 
	c.city_name, 
    ROUND((AVG(customer_total)), 0) AS average_sales
FROM 
(SELECT
cs.city_id,
cs.customer_id,
SUM(s.total) AS customer_total
FROM sales s
JOIN customers cs ON s.customer_id = cs.customer_id
GROUP BY 1, 2) AS customer_sales
JOIN city c ON customer_sales.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

-- 5. City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.
SELECT c.city_name, c.population, COUNT(DISTINCT cs.customer_id) AS coffee_consumers
FROM city c
LEFT JOIN customers cs ON c.city_id = cs.city_id
GROUP BY 1, 2
ORDER BY 1;

-- 6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
WITH ProductSales AS
(SELECT 
	c.city_name, 
    p.product_name, 
    COUNT(s.sale_id) AS sales_volume
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers cs ON s.customer_id = cs.customer_id
JOIN city c ON cs.city_id = c.city_id
GROUP BY 1, 2),
RankedProducts AS (
    SELECT 
        city_name,
        product_name,
        sales_volume,
        RANK() OVER (
            PARTITION BY city_name 
            ORDER BY sales_volume DESC
        ) AS rnk
    FROM ProductSales
)
SELECT 
    city_name,
    product_name,
    sales_volume
FROM RankedProducts
WHERE rnk <= 3
ORDER BY city_name, rnk;

-- 7. Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
SELECT 
	city_name, 
    COUNT(DISTINCT customer_name) AS total_customers
FROM customers cs
JOIN city c ON cs.city_id = c.city_id
GROUP BY 1
ORDER BY 1;

-- 8. Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
SELECT 
    c.city_name,
    ROUND(SUM(s.total) / COUNT(DISTINCT cu.customer_id), 2) AS avg_sale_per_customer,
    ROUND(c.estimated_rent / COUNT(DISTINCT cu.customer_id), 2) AS avg_rent_per_customer
FROM city c
JOIN customers cu 
    ON c.city_id = cu.city_id
JOIN sales s 
    ON cu.customer_id = s.customer_id
GROUP BY 
    c.city_name, c.estimated_rent
ORDER BY 
    c.city_name;
    
-- 9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
        SUM(total) AS total_sales
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
)
SELECT 
    sale_month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY sale_month) AS previous_month_sales,
    ROUND(
        ( (total_sales - LAG(total_sales) OVER (ORDER BY sale_month))
          / LAG(total_sales) OVER (ORDER BY sale_month) ) * 100,
        2
    ) AS pct_growth
FROM monthly_sales
ORDER BY sale_month;

-- 10. Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers
SELECT 
	c.city_name, 
    SUM(s.total) AS total_sales, 
    c.estimated_rent AS total_rent, 
    COUNT(DISTINCT cs.customer_id) AS total_customers
FROM sales s
JOIN customers cs ON s.customer_id = cs.customer_id
JOIN city c ON cs.city_id = c.city_id
GROUP BY 1, 3
ORDER BY 2 DESC
LIMIT 3;









 