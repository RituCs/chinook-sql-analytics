--Simple Counting

-- Count the rows in the invoice table where the billing_country is equal to "USA"
SELECT COUNT(*) AS usa_invoice_count 
FROM invoice 
WHERE billing_country = 'USA';

-- Count the rows for each billing country 
SELECT 
    billing_country,
    COUNT(*) AS invoice_count 
FROM invoice 
GROUP BY billing_country
ORDER BY invoice_count DESC;


--Aggregation and Grouping

-- Calculate the total sales amount for each invoice
SELECT 
    invoice_id,
    SUM(unit_price * quantity) AS total_amount
FROM invoice_line 
GROUP BY invoice_id 
ORDER BY total_amount DESC
LIMIT 5;

-- Count invoices and calculate average sales by state for USA
SELECT 
    billing_state,
    COUNT(*) AS invoice_count, 
    AVG(total) AS average_sale 
FROM invoice 
WHERE billing_country = 'USA' 
GROUP BY billing_state
ORDER BY average_sale DESC;

--Multi-level Grouping

-- Count and average sales by country and state
SELECT 
    billing_country,
    billing_state,
    COUNT(*) AS invoice_count, 
    AVG(total) AS average_sale 
FROM invoice 
GROUP BY billing_country, billing_state
ORDER BY billing_country, average_sale DESC;

--Filtering with WHERE and HAVING

-- Only show country/state combinations with more than 7 invoices
SELECT 
    billing_country,
    billing_state,
    COUNT(*) AS invoice_count, 
    AVG(total) AS average_sale  
FROM invoice  
GROUP BY billing_country, billing_state 
HAVING COUNT(*) > 7
ORDER BY invoice_count DESC;

-- Min and max sales for locations with average sales below $10
SELECT 
    billing_country, 
    billing_state, 
    MIN(total) AS min_sale, 
    MAX(total) AS max_sale,
    AVG(total) AS avg_sale
FROM invoice
GROUP BY billing_country, billing_state
HAVING AVG(total) < 10
ORDER BY avg_sale;

-- Combining WHERE and HAVING
-- Filter non-null states first, then filter by average
SELECT 
    billing_country, 
    billing_state, 
    MIN(total) AS min_sale, 
    MAX(total) AS max_sale,
    AVG(total) AS avg_sale
FROM invoice
WHERE billing_state <> 'None' AND billing_state IS NOT NULL
GROUP BY billing_country, billing_state
HAVING AVG(total) < 10
ORDER BY billing_country, avg_sale;

--Joins

-- Inner join between invoice and customer
SELECT 
    i.invoice_id, 
    i.invoice_date, 
    i.total AS invoice_total,
    c.customer_id, 
    c.first_name,
    c.last_name,
    c.email
FROM invoice AS i
JOIN customer AS c ON c.customer_id = i.customer_id
ORDER BY i.invoice_date DESC
LIMIT 10;

-- Join invoice_line with track to see track details for each line item
SELECT 
    il.invoice_id,
    il.track_id,
    t.name AS track_name,
    t.unit_price,
    il.quantity,
    (il.unit_price * il.quantity) AS line_total
FROM invoice_line AS il
JOIN track AS t ON il.track_id = t.track_id
ORDER BY il.invoice_id;

-- Filter joined results with WHERE
SELECT 
    il.invoice_id,
    il.track_id,
    t.name AS track_name,
    t.composer,
    il.unit_price,
    il.quantity
FROM invoice_line AS il
JOIN track AS t ON il.track_id = t.track_id
WHERE il.invoice_id = 19
ORDER BY t.name;

--Multi-table Joins

-- Three-table join to get invoice, customer, and employee information
SELECT 
    i.invoice_id,
    i.invoice_date,
    i.total AS invoice_total,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name
FROM invoice AS i
JOIN customer AS c ON i.customer_id = c.customer_id
JOIN employee AS e ON e.employee_id = c.support_rep_id
ORDER BY i.invoice_date DESC;

-- Count tracks by genre with proper joins and column naming
SELECT 
    g.name AS genre,
    COUNT(t.track_id) AS track_count
FROM genre AS g
JOIN track AS t ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY track_count DESC;

--Common Table Expressions (CTEs)

-- Use CTE to find top customers by total spending
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(i.total) AS total_spent
    FROM customer AS c
    JOIN invoice AS i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending
ORDER BY total_spent DESC
LIMIT 10;

--Self Joins
-- Find employees and their managers

SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    m.employee_id AS manager_id,
    m.first_name || ' ' || m.last_name AS manager_name
FROM employee e
LEFT JOIN employee m ON e.reports_to = m.employee_id
ORDER BY manager_name, employee_name;


--Chinook is investigating the possibility of offering a new feature in their service: 
--a matchmaking service that pairs you with another user for joint music listening and chatter. 
--To assess whether there's potential in this idea, a data scientist asked you for a table that pairs each 
--customer with every other customer and includes information about the customers.

SELECT c1.customer_id, c1.first_name, c1.last_name, c1.country, c1.email,
       c2.customer_id AS customer_id_2, c2.first_name AS first_name_2, c2.last_name AS last_name_2, c2.country AS country_2, c2.email AS email_2
  FROM customer AS c1
 CROSS JOIN customer AS c2
 WHERE c1.customer_id <> c2.customer_id;

--Provide a list of all songs in track and the number of times each track appeared in purchases during 2020. 
--For each track, include the following information:
SELECT t.track_id, t.name, 
  COUNT(CASE WHEN EXTRACT(YEAR FROM i.invoice_date) = 2021 THEN i.invoice_id END) as no_of_purchases
FROM track AS t
LEFT JOIN invoice_line AS il ON t.track_id = il.track_id
LEFT JOIN invoice as i ON il.invoice_id = i.invoice_id
GROUP BY t.track_id, t.name
order by no_of_purchases desc;

-- PostgreSQL we need to explicitly cast the date to text before using string operations like LIKE
SELECT invoice_id,invoice_date 
FROM invoice 
WHERE invoice_date::text LIKE '2022%';

SELECT invoice_id,invoice_date 
FROM invoice 
WHERE CAST(invoice_date AS text) LIKE '2023%';

SELECT invoice_id,invoice_date
FROM invoice 
WHERE EXTRACT(YEAR FROM invoice_date) = 2022;

