-- ----------------------------------------
-- REAL-WORLD SQL: ESSENTIALS
-- ----------------------------------------

SELECT title, description
FROM film AS f
INNER JOIN language AS l
  ON f.language_id = l.language_id
WHERE l.name IN ('Italian', 'French')
  AND f.release_year = 2005 ;
  

SELECT c.first_name,
	     c.last_name,
       p.amount
FROM payment AS p
INNER JOIN customer AS c
  ON p.customer_id = c.customer_id
WHERE c.active = 'true'
ORDER BY p.amount DESC;  


SELECT LOWER(title) AS title, 
  rental_rate AS original_rate, 
  rental_rate * 0.5 AS sale_rate 
FROM film
-- Filter for films prior to 2006
WHERE release_year < 2006;


SELECT payment_date,
  EXTRACT(DAY FROM payment_date) AS payment_day 
FROM payment;


SELECT active, 
       COUNT(payment_id) AS num_transactions, 
       AVG(amount) AS avg_amount, 
       SUM(amount) AS total_amount
FROM payment AS p
INNER JOIN customer AS c
  ON p.customer_id = c.customer_id
GROUP BY active;


-- ----------------------------------------
-- FINDING THE DATA
-- DATABASE TABLES: pg_catalog.pg_tables, information_schema.columns
-- ----------------------------------------
  
SELECT * 
FROM payment
ORDER BY amount DESC
LIMIT 10; 

SELECT * 
FROM pg_catalog.pg_tables -- list all of the tablea that exist in your database
WHERE schemaname = 'public';
  

-- Explore the tables and fill in the correct one
SELECT * 
FROM payment 
LIMIT 10;

-- Prepare the result
SELECT EXTRACT(MONTH FROM payment_date) AS month, 
       SUM(amount) AS total_payment
FROM payment 
GROUP BY month;


SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'public';

-- Create a new view called table_columns
CREATE VIEW table_columns AS
SELECT table_name, 
	   STRING_AGG(column_name, ', ') AS columns
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY table_name;

-- Query the newly created view table_columns
SELECT *
FROM table_columns;



SELECT title, COUNT(title)
FROM film AS f
INNER JOIN inventory AS i
  ON f.film_id = i.film_id
INNER JOIN rental AS r
  ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY count DESC;


-- ----------------------------------------
-- STORING THE DATA
-- CREATE TABLE .. (), INSERT INTO .. () VALUES ('..','..'), UPDATE .. SET .., DELETE FROM, 
-- ----------------------------------------

-- Create a new table called oscars
CREATE TABLE oscars (
    title VARCHAR,
    award VARCHAR
);

-- Insert the data into the oscars table
INSERT INTO oscars (title, award)
VALUES
('TRANSLATION SUMMER', 'Best Film'),
('DORADO NOTTING', 'Best Film'),
('MARS ROMAN', 'Best Film'),
('CUPBOARD SINNERS', 'Best Film'),
('LONELY ELEPHANT', 'Best Film');

-- Confirm the table was created and is populated
SELECT * 
FROM oscars;

-- Create a new table named family_films using this query
CREATE TABLE family_films AS
SELECT *
FROM film
WHERE rating IN ('G', 'PG');

-- Increase rental_rate by one dollar for R-rated movies
UPDATE film
SET rental_rate = rental_rate + 1
WHERE rating = 'R'


UPDATE film
SET rental_rate = rental_rate - 1
WHERE film_id IN
  (SELECT film_id from actor AS a
   INNER JOIN film_actor AS f
      ON a.actor_id = f.actor_id
   WHERE last_name IN ('WILLIS', 'CHASE', 'WINSLET', 'GUINESS', 'HUDSON'));
   
   
-- Delete films that cost most than 25 dollars
DELETE FROM film
WHERE replacement_cost > 25


-- Use the list of film_id values to DELETE all R & NC-17 rated films from inventory.
DELETE FROM inventory
WHERE film_id IN (
  SELECT film_id FROM film
  WHERE rating IN ('R', 'NC-17')
);

-- Delete records from the `film` table that are either rated as R or NC-17.
DELETE FROM film
WHERE rating IN ('R', 'NC-17')

-- ----------------------------------------
-- BEST PRACTICES TO WRITE SQL
-- ----------------------------------------

SELECT r.customer_id, r.rental_date, r.return_date 
FROM rental AS r
/* inventory is used to unite */ 
INNER JOIN inventory AS i
  ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
  ON i.film_id = f.film_id
WHERE f.length < 90;


SELECT category AS film_category, 
       AVG(length) AS average_length
FROM film AS f
INNER JOIN category AS c
  ON f.film_id = c.film_id
WHERE release_year BETWEEN 2005 AND 2010
GROUP BY category;


SELECT first_name, 
       last_name, 
       email 
FROM rental AS r 
INNER JOIN customer AS c 
   ON r.customer_id = c.customer_id;
   

