use DataWarehouseAnalytics;
select * from gold.dim_customers;
select * from gold.dim_products;
select * from gold.fact_sales;
--- CHANGE OVER TIME - TRENDS
select YEAR(order_date) YEAR, MONTH(ORDER_DATE) MONTH,
SUM(sales_amount) AS
tOTAL_SALES, COUNT(DISTINCT customer_key) TOTAL_CUSTOMERS,
SUM(QUANTITY) UNITS_SOLD, COUNT(DISTINCT PRODUCT_key)
AS TOTAL_PRODUCTS from gold.fact_sales WHERE YEAR(ORDER_DATE)
IS NOT NULL GROUP BY
YEAR(order_date), MONTH(ORDER_DATE)
ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE);
/*OR, WE CAN COMBINE THE YEAR AND MONTH TOGETHER. USING DATETRUNC
AND WE ARRIVE AT THE SAME OUTPUT*/
select DATETRUNC(MONTH,order_date) DATE,
SUM(sales_amount) AS
tOTAL_SALES, COUNT(DISTINCT customer_key) TOTAL_CUSTOMERS,
SUM(QUANTITY) UNITS_SOLD, COUNT(DISTINCT PRODUCT_key)
AS TOTAL_PRODUCTS from gold.fact_sales WHERE YEAR(ORDER_DATE)
IS NOT NULL GROUP BY  DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);
-- -----------------------------------------------------------------
/*CUMMULATIVE ANALYSIS: THE PROGRESS OF A BUSNESS OVER TIME
calculate the total sales per month and the running
total of sales over time*/
SELECT ORDER_DATE, tOTAL_SALES, SUM(tOTAL_SALES) OVER
(ORDER BY ORDER_DATE) RUNNING_TOTAL
FROM 
(select DATETRUNC(MONTH,order_date) ORDER_DATE,
SUM(sales_amount) AS
tOTAL_SALES from gold.fact_sales WHERE YEAR(ORDER_DATE)
IS NOT NULL GROUP BY  DATETRUNC(MONTH,order_date))F;
/*We can als look at the running avg along
side the running total in terms of year*/

SELECT ORDER_DATE, tOTAL_SALES, avg_sales, SUM(tOTAL_SALES)
OVER (ORDER BY ORDER_DATE) RUNNING_TOTAL,
avg(avg_sales) over 
(ORDER BY ORDER_DATE) RUNNING_average
FROM (
select DATETRUNC(year,order_date) ORDER_DATE,
SUM(sales_amount) AS tOTAL_SALES, AVG(sales_amount) avg_sales
from gold.fact_sales
WHERE YEAR(ORDER_DATE)
IS NOT NULL GROUP BY  DATETRUNC(YEAR,order_date))F;
-- -----------------------------------------------------------------
/*PERFORMANCE ANALYSIS
ANALYZE THE YEARLY PERFORMANCE OF PRODUCTS BY
COMPARING EACH PRODUCT'S SALES TO BOTH
IT'S AVG SALES PERFORMANCE AND PREVIOUS YEAR'S SALE*/
WITH CTE_PERFORMANCE AS
(SELECT YEAR(F.ORDER_DATE) YEAR, P.product_name,
SUM(SALES_AMOUNT) CURRENT_SALES
FROM GOLD.fact_sales F JOIN GOLD.dim_products P ON
F.product_key=P.product_key WHERE F.order_date IS NOT NULL
GROUP BY YEAR(F.ORDER_DATE), P.product_name)
SELECT YEAR, PRODUCT_NAME, CURRENT_SALES,
AVG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME) AVG_SALES,
CURRENT_SALES-AVG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME)
DIFF_IN_AVG, CASE WHEN CURRENT_SALES-AVG(CURRENT_SALES) OVER
(PARTITION BY PRODUCT_NAME) >0 THEN 'ABOVE AVERAGE'
WHEN CURRENT_SALES-AVG(CURRENT_SALES) OVER
(PARTITION BY PRODUCT_NAME) <0 THEN 'BELOW AVERAGE' ELSE 'AVERAGE'
END AS AVG_CHANGE,
LAG(CURRENT_SALES) OVER (PARTITION BY PRODUCT_NAME ORDER BY YEAR)
PY_SALES, CURRENT_SALES- LAG(CURRENT_SALES) OVER 
(PARTITION BY PRODUCT_NAME ORDER BY YEAR) CHANGE_IN_SALES,
CASE WHEN CURRENT_SALES-LAG(CURRENT_SALES) OVER
(PARTITION BY PRODUCT_NAME ORDER BY YEAR) >0 THEN 'INCREASING'
WHEN CURRENT_SALES-LAG(CURRENT_SALES) OVER
(PARTITION BY PRODUCT_NAME ORDER BY YEAR) <0 THEN 'DECREASING' 
ELSE 'NO CHANGE' END AS SALES_STATUS
FROM CTE_PERFORMANCE;
-- -------------------------------------------------------
-- WHICH CATEGORY CONTRIBUTED THE MOST TO THE OVERALL SALES?
WITH CTE_MOST_OVERALL AS
(SELECT P.category, SUM(F.sales_amount) TOTAL_SALES 
FROM GOLD.fact_sales F LEFT JOIN GOLD.dim_products P
ON F.product_key=P.product_key WHERE F.order_date IS NOT NULL
GROUP BY P.CATEGORY),
CTE_MOST_OVERALL_1 AS
(SELECT CATEGORY, TOTAL_SALES, SUM(TOTAL_SALES) OVER() AS
GRAND_TOTAL FROM CTE_MOST_OVERALL)
SELECT *, CONCAT(CAST((CAST(TOTAL_SALES AS FLOAT)/GRAND_TOTAL)*100
AS DECIMAL (10,2)),'%') AS PERCENT_OF_TOTAL FROM CTE_MOST_OVERALL_1
ORDER BY TOTAL_SALES DESC;
-- --------------------------------------------------------
/* DATA SEGMENTATION-
SEGMENT PRODUCTS INTO COST RANGES AND COUNT HOW MANY PRODUCTS THAT
FALL INTO EACH RANGE*/
select cost_range, count(product_key) as product_count from
(SELECT product_key, product_name, COST,
CASE WHEN cost <100 THEN 'Below 100'
when cost between 100 and 500 then '100-500'
when cost between 500 and 1000 then '500-1000'
else 'Above 1000' end as Cost_Range
FROM GOLD.dim_products)h group by Cost_Range
order by product_count desc;
-- ---------------------------------------------------------------
/*GROUP CUSTOMERS INTO 3 SEGMENTS BASED ON THEIR SPENDING BEHAVIOUR:
VIP:CUSTOMERS WITH AT LEAST 12 MONTHS OF HISTORY
AND SPENDING > THAN $5K
REGULAR:CUSTOMERS WITH AT LEAST 12 MONTHS OF HISTORY
AND SPENDING < THAN $5K
NEW:CUSTOMERS WITH A LIFESPAN LESS THAN 12 MONTHS.
AND FIND THE TOTAL NO OF CUSTOMERS BY EACH GROUP*/
SELECT SEGMENT, COUNT(CUSTOMER_KEY) CUSTOMER_COUNT FROM
(SELECT customer_key, CASE WHEN TOTAL_SPENDING > 5000
AND LIFESPAN >= 12 THEN 'VIP'
WHEN TOTAL_SPENDING < 5000 AND LIFESPAN >= 12 THEN 'REGULAR'
WHEN LIFESPAN < 12 THEN 'NEW' END AS SEGMENT
FROM
(SELECT *, DATEDIFF(MONTH,FIRST_ORDER_DATE,
LAST_ORDER_DATE) LIFESPAN FROM
(SELECT C.customer_key, SUM(F.sales_amount) AS TOTAL_SPENDING,
MIN(F.ORDER_DATE) AS FIRST_ORDER_DATE,
MAX(F.ORDER_DATE) AS LAST_ORDER_DATE
FROM GOLD.dim_customers C LEFT JOIN
GOLD.fact_sales F ON C.customer_key=F.customer_key
WHERE F.order_date IS NOT NULL
GROUP BY C.customer_key)D)HANNA)ADA GROUP BY SEGMENT
ORDER BY CUSTOMER_COUNT DESC;
-- ----------------------------------------------------------
/* CUSTOMER REPORTS
PURPOSE: THIS REPORT CONSOLIDATES KEY CUSTOMER
METRICS AND BEHAVIORS
HIGHLIGHTS:
1.GATHERS ESSENTIAL FIELDS SUCH AS NAMES,AGES,
AND TRANSACTION DETAILS
2.SEGMENT CUSTOMERS INTO CATEGORIES(VIP,REGULAR,NEW)
AND AGE GROUPS
3.AGGREGATE CUSTOMER-LEVEL METRICS:
TOTAL ORDERS, TOTAL QUANTITY PURCHASED, TOTAL SALES, TOTAL PRODUCTS,
LIFESPAN(IN MONTHS)
4.CALCULATE VALUABLE KPIs:
- RECENCY (MONTHS SINCE LAST ORDER)
- AVERAGE ORDER VALUE
AVERAGE MONTHLY SPENDING*/
-- ---------------------------------------------------------------
/* REPORT BUILDING
-1. BASE QUERY: RETRIEVE CORE COLUMNS FROM TABLE*/
drop view gold.REPORT_CUSTOMERS;
CREATE VIEW GOLD.REPORT_CUSTOMERS AS /*VIEW FOR THE REPORT*/
WITH CTE_BASE AS
 (SELECT F.order_number, F.order_date, F.product_key,
 F.sales_amount, F.quantity, C.customer_key,
 C.birthdate,C.customer_number,
 CONCAT(C.FIRST_NAME,' ',C.last_name) AS CUSTOMER_NAME,
 DATEDIFF(YEAR, C.birthdate, GETDATE()) AGE
 FROM GOLD.fact_sales F LEFT JOIN GOLD.dim_customers C
 ON F.customer_key=C.customer_key WHERE F.order_date IS NOT NULL),
 CTE_BASE2 AS
 (SELECT customer_key, customer_number,CUSTOMER_NAME,AGE,
 -- AGGREGATING CUSTOMER-LEVEL METRICS
 COUNT(DISTINCT order_number) TOTAL_ORDERS, SUM(SALES_AMOUNT)
 AS TOTAL_SALES, SUM(QUANTITY) AS TOTAL_QUANTITY,
 COUNT(DISTINCT product_key) TOTAL_PRODUCTS,
 MAX(ORDER_DATE) AS LAST_ORDER_DATE,
 -- GET THE LIFESPAN OF CUSTOMERS
 DATEDIFF(MONTH, MIN(ORDER_DATE), MAX(ORDER_DATE)) LIFESPAN
 FROM CTE_BASE GROUP BY customer_key, customer_number,
CUSTOMER_NAME,AGE)
SELECT customer_key, customer_number,CUSTOMER_NAME,AGE,
-- GET CUSTOMERS SEGMENT
CASE WHEN TOTAL_SALES > 5000
AND LIFESPAN >= 12 THEN 'Vip'
WHEN TOTAL_SALES < 5000 AND LIFESPAN >= 12 THEN 'Regular'
WHEN LIFESPAN < 12 THEN 'New' END AS Segment,
-- GET AGE RANGE OF CUSTOMERS
CASE WHEN AGE <20 THEN 'Under 20'
WHEN AGE BETWEEN 20 AND 29 THEN '20-29'
WHEN AGE BETWEEN 30 AND 39 THEN '30-39'
WHEN AGE BETWEEN 40 AND 49 THEN '40-49'
ELSE '50 and above' END AS AGE_RANGE,
/*GET THE DIFF B/W LAST ORDER DATE AND CURRENT DATE IN MONTH
TO BE RECENCY VALUE*/
DATEDIFF(MONTH, LAST_ORDER_DATE, GETDATE()) RECENCY,
TOTAL_ORDERS,TOTAL_SALES,TOTAL_QUANTITY,TOTAL_PRODUCTS,
LAST_ORDER_DATE, LIFESPAN,
-- GET THE AVG ORDER VALUE WHICH IS TOTAL_SALES/TOTAL_ORDERS
TOTAL_SALES/TOTAL_ORDERS AS AVG_ORDER_VALUE,
--COMPUTE AVG MONTHLY SPENDING
CASE WHEN LIFESPAN=0 THEN TOTAL_SALES
ELSE TOTAL_SALES/LIFESPAN END AS AVG_MONTHLY_SPENT
FROM CTE_BASE2;
-- ------------------------------------------------------
SELECT * FROM GOLD.REPORT_CUSTOMERS;
-- ---------------------------------------------------------
-- create a product report
CREATE VIEW GOLD.REPORT_PRODUCTS AS /* VIEW TO KEEP THE REPORT*/
with base_query as
-- 1.Retrieve core cols from fact and products tables------------
(select f.order_number, f.order_date,f.customer_key,
f.sales_amount,f.quantity,p.product_key,
p.product_name,p.category,p.subcategory,p.cost
from gold.fact_sales f left join gold.dim_products p
on f.product_key=p.product_key
WHERE F.order_date IS NOT NULL),
product_aggregations as
-- 2.Product Aggregations:summarize key metrics at the product level
(select product_key,product_name,category,subcategory,cost,
DATEDIFF(month,MIN(order_date), max(order_date)) lifespan,
MAX(order_date) last_sale_date,COUNT(distinct order_number)
total_orders, COUNT(distinct customer_key) total_customer,
SUM(sales_amount) total_sales,SUM(quantity) total_quantity,
round(AVG(cast(sales_amount as float) / nullif(quantity,0)),1)
avg_selling_price from base_query group by
product_key,product_name,category,subcategory,cost)
-- 3.final query:combine all products results into one
select product_key,product_name,category,subcategory,cost
last_sale_date, DATEDIFF(month,last_sale_date,getdate())
recency_in_months, case when total_sales >50000
then'High Performer' when total_sales >=1000 then'Mid Range'
else 'Low Performer' end as product_segment, lifespan,
total_sales, total_orders, total_quantity,total_customer,
avg_selling_price,
-- Average order revenue (AOR)
case when total_orders =0 then 0 else
total_sales / total_orders end as avg_order_revenue,
--Average monthly revenue (AMR)
case when lifespan =0 then total_sales else
total_sales / lifespan end as avg_monthly_revenue
from product_aggregations;
-- ---------------------------------------------------------
SELECT * FROM GOLD.REPORT_PRODUCTS;
--              END----------------------------------
