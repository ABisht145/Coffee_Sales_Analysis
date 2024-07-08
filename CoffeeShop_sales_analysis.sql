/* CREATING DATABASE */
CREATE DATABASE IF NOT EXISTS coffee_sales;

/* USING THE DATABASE */
USE coffee_sales;

/* IMPORTING TABLE
We have imported the table from a csv file. Now, we have to updates the datatypes and constraints to the columns also the names of the columns in correct and understandable format.*/
UPDATE coffee_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y'); 
/* Updating the dates in correct format*/

ALTER TABLE coffee_sales
MODIFY COLUMN transaction_date DATE; 
/* Updating the datatype of the column consisting dates */

UPDATE coffee_sales
SET transaction_time=STR_TO_DATE(transaction_time,'%H:%i:%s'); 
/* Updating the time in correct format */

ALTER TABLE coffee_sales
MODIFY COLUMN transaction_time TIME; -- Updating the datatype of the column consisting time

/* DESCRIBING THE COLUMNS OF THE TABLE, THEIR DATATYPE AND CONSTRAINTS */
DESCRIBE coffee_sales;


/* TOTAL SALES AND SALES OF EACH MONTH*/
SELECT SUM(unit_price*transaction_qty) AS Total_Sales
FROM coffee_sales;  -- Total sales throughout

SELECT MONTHNAME(transaction_date) AS Month,
       ROUND(SUM(unit_price*transaction_qty),2) AS Sales
FROM coffee_sales
GROUP BY MONTHNAME(transaction_date); 


/* MONTH-ON-MONTH INCREASE OR DECREASE PERCENTAGE IN SALES*/
SELECT MONTH(transaction_date) AS Month,
       CONCAT(ROUND((SUM(unit_price*transaction_qty)-LAG(SUM(unit_price*transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))) /  LAG(SUM(unit_price*transaction_qty),1) OVER (ORDER BY MONTH(transaction_date)) * 100,2),"%") AS MOM_increase_percentage
FROM coffee_sales
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);


/* TOTAL NUMBER OF ORDERS AND NUMBER OF ORDERS IN EACH MONTH*/
SELECT SUM(transaction_id) AS Total_Orders
FROM coffee_sales;  -- Total Number of Orders

SELECT MONTHNAME(transaction_date) AS Month,
       COUNT(transaction_id) AS Number_of_Orders
FROM coffee_sales
GROUP BY MONTHNAME(transaction_date); -- Number of Orders Each Month


/* MONTH-ON-MONTH INCREASE OR DECREASE PERCENTAGE IN NUMBER OF ORDERS */
SELECT MONTH(transaction_date) AS Month,
       CONCAT(ROUND(((COUNT(transaction_id)-LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date))) /  LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date))) * 100,2),"%") AS MOM_increase_percentage
FROM coffee_sales
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);


/* TOTAL NUMBER OF ORDERS AND NUMBER OF ORDERS IN EACH MONTH*/
SELECT SUM(transaction_qty) AS Total_Quantity_Sold
FROM coffee_sales;  -- Total Quantity Sold

SELECT MONTHNAME(transaction_date) AS Month,
       SUM(transaction_qty) AS Quantity_Sold
FROM coffee_sales
GROUP BY MONTHNAME(transaction_date); -- Quantity Sold Each Month


/* MONTH-ON-MONTH INCREASE OR DECREASE PERCENTAGE IN QUANTITY_SOLD*/
SELECT MONTH(transaction_date) AS Month,
       CONCAT(ROUND(((SUM(transaction_qty)-LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))) /  LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))) * 100,2),"%") AS MOM_increase_percentage
FROM coffee_sales
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);


/* DAILY ANALYSIS OF A COMPLETE MONTH (let's say March) */
SELECT DAY(transaction_date) AS Day_of_month,
       ROUND(SUM(unit_price*transaction_qty),2) AS Sales,
       COUNT(transaction_id) AS No_of_Orders,
       SUM(transaction_qty) AS Quantity_Sold
FROM coffee_sales
WHERE MONTH(transaction_date)=3
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date); -- Here we can take any month from the dataset, here we have data of months from January to June


/* COMPARING SALES OF EACH MONTH WITH THE AVERAGE SALE */
SELECT Month,
       CASE 
          WHEN total_sales > avg_sales THEN 'Above Average'
          WHEN total_sales < avg_sales THEN 'Below Average'
          ELSE 'Average'
       END AS sales_status
FROM (SELECT MONTHNAME(transaction_date) AS Month,
             SUM(unit_price * transaction_qty) AS total_sales,
             AVG(SUM(unit_price * transaction_qty)) OVER() AS avg_sales
      FROM coffee_sales
      GROUP BY MONTHNAME(transaction_date)) AS sales_data;


/* COMPARING DAILY SALES OF A MONTH WITH THE AVERAGE SALE OF THAT MONTH (Here March is taken) */
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;


/* COMPARISON ANALYSIS ON WEEKDAYS AND WEEKENDS  */
SELECT CASE
           WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN "Weekends"
           ELSE "Weekdays"
       END AS Day_type,
       ROUND(SUM(transaction_qty*unit_price),2) as Sales
FROM coffee_sales
GROUP BY CASE
           WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN "Weekends"
           ELSE "Weekdays"
       END;


/* ANALYSIS OF ALL THE STORES OVER THE GIVEN TIME */
SELECT store_location,
       COUNT(transaction_id) AS No_of_Orders,
       SUM(transaction_qty) AS Quantity_Sold,
	   ROUND(SUM(transaction_qty*unit_price),2) AS Sales
FROM coffee_sales
GROUP BY store_location
ORDER BY Sales DESC;


/* ANALYSIS OF ALL THE PRODUCT TYPES AND CATEGORY OVER THE GIVEN TIME */
SELECT product_category,
       COUNT(transaction_id) AS No_of_Orders,
       SUM(transaction_qty) AS Quantity_Sold,
	   ROUND(SUM(transaction_qty*unit_price),2) AS Sales
FROM coffee_sales
GROUP BY product_category;

SELECT product_type,
       COUNT(transaction_id) AS No_of_Orders,
       SUM(transaction_qty) AS Quantity_Sold,
	   ROUND(SUM(transaction_qty*unit_price),2) AS Sales
FROM coffee_sales
GROUP BY product_type;


/* TOP 5 PRODUCT TYPE BY SALES*/
SELECT product_type,
       ROUND(SUM(transaction_qty*unit_price),2) AS Sales
FROM coffee_sales
GROUP BY product_type
ORDER BY Sales DESC
LIMIT 5;


/* HOURLY BASED ANALYSIS */
SELECT HOUR(transaction_time) AS A,
       COUNT(transaction_id) AS No_of_Orders,
       SUM(transaction_qty) AS Quantity_Sold,
	   ROUND(SUM(transaction_qty*unit_price),2) AS Sales
FROM coffee_sales
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);


/* ANALYSIS OF ALL DAYS OF A WEEK */
SELECT CASE
	     WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
         WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
         WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
         WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
         WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
         WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
         ELSE 'Sunday'
       END AS Day_of_Week,
       COUNT(transaction_id) AS No_of_Orders,
       SUM(transaction_qty) AS Quantity_Sold,
	   ROUND(SUM(transaction_qty*unit_price),2) AS Sales
FROM coffee_sales
GROUP BY CASE
	       WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
           WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
           WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
           WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
           WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
           WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
           ELSE 'Sunday'
       END;       
