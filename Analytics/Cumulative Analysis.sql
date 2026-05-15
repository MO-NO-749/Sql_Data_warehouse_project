/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT
	order_date,
	total_sales,
    avg_price,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t
;
WITH Cumulative_ AS 
( SELECT 
        customer_id
        ,customer_name
        ,total_Customers
        ,CAST(COUNT(customer_id) OVER(ORDER BY total_Customers_sales DESC,customer_id)AS decimal(10,2)) AS cumulative_Customer_count
        ,SUM(total_Customers_sales) OVER(ORDER BY total_Customers) as total_sales
        ,total_Customers_sales
        ,CAST(SUM(total_Customers_sales) OVER (order by total_Customers_sales DESC,customer_id) AS decimal(10,2))AS cumulative_sales 
FROM
(
SELECT c.customer_id
        , CONCAT(c.first_name,' ',c.last_name) AS customer_name
        ,COUNT(c.customer_id) OVER() AS total_Customers 
        ,COUNT(c.customer_id) OVER(ORDER BY c.customer_id)AS c
        ,SUM(s.sales_amount) AS total_Customers_sales
        
 FROM Gold.fact_sales s LEFT JOIN 
Gold.dim_customers c ON s.customer_key = c.customer_key
GROUP BY first_name,last_name,customer_id,s.sales_amount 
)t
)
SELECT 
customer_id
,customer_name
,cumulative_Customer_count
,total_Customers
,CAST((cumulative_Customer_count/total_Customers)*100 AS decimal (7,2))AS cumulative_cutomer_percentage
,cumulative_sales
,total_sales
,CAST((cumulative_sales/total_sales)*100 AS decimal(7,2)) AS cumulative_sales_percentage
FROM Cumulative_
ORDER BY total_Customers_sales DESC
