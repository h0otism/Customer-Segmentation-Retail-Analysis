-- SQL Retail Sales Analysis
CREATE DATABASE retail_sale_project;

-- Create TABLE

 -- 1. Remove the existing table that has the wrong data types
DROP TABLE IF EXISTS retail_sales;

 -- 2. Create the table with approriate string types for identifiers
CREATE TABLE retail_sales
		(
			transaction_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- The Surrogate Key
			invoice_no VARCHAR(20),
			stock_code VARCHAR(20),
			description TEXT,
			quantity INT,
			invoice_date DATE,
			unit_price FLOAT,
			customer_id INT,
			country VARCHAR(100)
		);


SELECT 
    COUNT(*) as total_rows, 
    MIN(transaction_id) as first_id, 
    MAX(transaction_id) as last_id 
FROM retail_sales
-- Ensure all rows from the Excel file made it into the database and transaction_id generated correctly

-- 3. Check if there are any nulls values in all columns
SELECT 
    COUNT(*) - COUNT(invoice_no) AS null_invoice,
    COUNT(*) - COUNT(stock_code) AS null_stockcode,
    COUNT(*) - COUNT(customer_id) AS null_customer,
    COUNT(*) - COUNT(description) AS null_description
FROM retail_sales;

DELETE FROM retail_sales
WHERE customer_id IS NULL; -- Delete all null values from customer_id column

-- 4. Handling duplicate values
SELECT 
		invoice_no, 
		stock_code, 
		description, 
		quantity, 
		invoice_date, 
		unit_price, 
		customer_id, 
		country, 
	COUNT(*)
FROM retail_sales
GROUP BY 
		invoice_no, 
		stock_code, 
		description, 
		quantity, 
		invoice_date, 
		unit_price, 
		customer_id, 
		country
HAVING COUNT(*) > 1;

DELETE FROM retail_sales
WHERE transaction_id IN (
	SELECT transaction_id
	FROM (
		SELECT transaction_id,
			   ROW_NUMBER() OVER (
					PARTITION BY 
						invoice_no, 
						stock_code, 
						quantity, 
						invoice_date, 
						unit_price, 
						customer_id
					ORDER BY transaction_id
			   ) as row_num
		FROM retail_sales
	) t
	WHERE t.row_num > 1
);
-- Keep the row with the lowest transaction_id and deletes the rest

--Remove cancellations
DELETE FROM retail_sales
WHERE invoice_no LIKE 'C%';

-- 1. Imputation: Removed ~135,000 records missing CustomerID as they could not be used for individual segmentation
-- 2. Deduplication: Identified and removed duplicate transaction logs using SQL window functions (ROW_NUMBER) to ensure revenue was not double-counted
-- 3. Logical Cleaning: Filtered out 'C' prefixed invoices to excluded cancelled orders from the final RFM model


-- Exploratory Data Analysis (EDA)

-- How many total transactions, unique customers, and unique products do we have?

SELECT 
	COUNT(*) AS total_rows,
	COUNT(DISTINCT invoice_no) AS total_orders,
	COUNT(DISTINCT customer_id) AS unique_customers,
	COUNT(DISTINCT stock_code) AS unique_products,
	MIN(invoice_date) AS first_sale,
	MAX(invoice_date) AS last_sale
FROM retail_sales;

-- What are the top 5 countries by total revenue?
SELECT 
    country, 
    ROUND(SUM(quantity * unit_price)::numeric, 2) AS total_revenue
FROM retail_sales
WHERE quantity > 0 -- Exclude returns
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 5;

-- How does revenue trend month-over-month?
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    ROUND(SUM(quantity * unit_price)::numeric, 2) AS monthly_revenue,
    COUNT(DISTINCT invoice_no) AS num_transactions
FROM retail_sales
WHERE quantity > 0
GROUP BY 1
ORDER BY 1;

-- What are the top 10 best-selling products by quantity?
SELECT 
    description, 
    SUM(quantity) AS total_sold
FROM retail_sales
WHERE description IS NOT NULL AND quantity > 0
GROUP BY description
ORDER BY total_sold DESC
LIMIT 10;

-- How many transactions are actually "Returns" (Negative quantity)?
SELECT 
    COUNT(*) AS return_count,
    ROUND(SUM(quantity * unit_price)::numeric, 2) AS total_refunded_value
FROM retail_sales
WHERE quantity < 0;

-- How many sales happened without a CustomerID? (The "Guest" problem)
SELECT 
    COUNT(*) AS guest_transactions,
    ROUND(SUM(quantity * unit_price)::numeric, 2) AS guest_revenue
FROM retail_sales
WHERE customer_id IS NULL;

-- RFM Metrics

WITH reference_date_cte AS (
    -- Find the last day in the dataset to act as "today"
    SELECT MAX(invoice_date) + 1 as analysis_date FROM cleaned_retail_data
),
rfm_raw AS (
    SELECT 
        customer_id,
        -- RECENCY: Difference between analysis date and last purchase
        (SELECT analysis_date FROM reference_date_cte) - MAX(invoice_date) as recency,
        
        -- FREQUENCY: Count of unique invoice numbers
        COUNT(DISTINCT invoice_no) as frequency,
        
        -- MONETARY: Sum of all line item totals
        SUM(line_item_total) as monetary
    FROM cleaned_retail_data
    GROUP BY customer_id
)
SELECT * FROM rfm_raw;

-- Create TABLE for K-means clustering

CREATE TABLE rfm_scores AS
WITH reference_date_cte AS (
    SELECT MAX(invoice_date) + 1 as analysis_date FROM cleaned_retail_data
)
SELECT 
    customer_id,
    (SELECT analysis_date FROM reference_date_cte) - MAX(invoice_date) as recency,
    COUNT(DISTINCT invoice_no) as frequency,
    SUM(line_item_total) as monetary
FROM cleaned_retail_data
GROUP BY customer_id;

SELECT * FROM rfm_scores;

