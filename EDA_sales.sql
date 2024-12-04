select * from sds_copy2;

-- Total Rows
 
SELECT COUNT(*) AS Total_Records FROM sds_copy2;

-- Statistics for Numerical Columns 

SELECT 
    MIN(SALES) AS Min_Sales, MAX(SALES) AS Max_Sales, AVG(SALES) AS Avg_Sales, SUM(SALES) AS Total_Sales,
    MIN(QUANTITYORDERED) AS Min_Quantity, MAX(QUANTITYORDERED) AS Max_Quantity, AVG(QUANTITYORDERED) AS Avg_Quantity
FROM sds_copy2;

-- field based analysis (PRODUCTLINE) 

select max(QUANTITYORDERED), PRODUCTLINE
from sds_copy2
group by PRODUCTLINE;

select COUNTRY, max(PRODUCTLINE) from sds_copy2
group by COUNTRY order by 2 DESC;

select PRODUCTLINE, `STATUS`, count(PRODUCTLINE)
from sds_copy2
group by PRODUCTLINE, `STATUS`
order by PRODUCTLINE ;

-- date time analysis

SELECT YEAR_ID, SUM(SALES) AS Total_Sales 
FROM sds_copy2 
GROUP BY YEAR_ID 
ORDER BY YEAR_ID;

SELECT MONTH_ID, SUM(SALES) AS Total_Sales 
FROM sds_copy2 
GROUP BY MONTH_ID 
ORDER BY MONTH_ID;

-- Customer and Location Insights

SELECT COUNTRY, SUM(SALES) AS Total_Sales 
FROM sds_copy2
GROUP BY COUNTRY 
ORDER BY Total_Sales DESC;

SELECT CUSTOMERNAME, SUM(SALES) AS Total_Sales 
FROM sds_copy2 
GROUP BY CUSTOMERNAME 
ORDER BY Total_Sales DESC 
LIMIT 10;

-- 	Comulative sales by month

SELECT YEAR_ID, MONTH_ID, SUM(SALES) AS Monthly_Sales,
       SUM(SUM(SALES)) OVER (PARTITION BY YEAR_ID ORDER BY MONTH_ID) AS Cumulative_Sales
FROM sds_copy2
GROUP BY YEAR_ID, MONTH_ID
ORDER BY YEAR_ID, MONTH_ID;

-- above avg sales orders

WITH AverageSales AS (
    SELECT AVG(SALES) AS Avg_Sales From sds_copy2
)
SELECT ORDERNUMBER, SALES, CUSTOMERNAME
FROM sds_copy2, AverageSales
WHERE SALES > Avg_Sales;

-- yealry sales growth

WITH YearlySales AS (
    SELECT YEAR_ID, SUM(SALES) AS Total_Sales
    FROM sds_copy2
    GROUP BY YEAR_ID
),
SalesGrowth AS (
    SELECT YEAR_ID, Total_Sales, 
           LAG(Total_Sales) OVER (ORDER BY YEAR_ID) AS Previous_Year_Sales,
           (Total_Sales - LAG(Total_Sales) OVER (ORDER BY YEAR_ID)) / LAG(Total_Sales) OVER (ORDER BY YEAR_ID) * 100 AS Growth_Percentage
    FROM YearlySales
)
SELECT * FROM SalesGrowth;

 

 


