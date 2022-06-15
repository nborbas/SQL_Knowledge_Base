-- ----------------------------------------
-- GETTING INFORMATION ABOUT THE DATABASE - DATA TYPES
-- ----------------------------------------

-- Select all columns from the TABLES system database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES
 -- Filter by schema
WHERE table_schema = 'public';
 
 
-- Get the column name and data type
SELECT
	column_name, 
	data_type
-- From the system database information schema
FROM INFORMATION_SCHEMA.COLUMNS 
-- For the customer table
WHERE table_name = 'customer';

-- ----------------------------------------
-- ARRAYS - TYPE: TEXT[]
-- ANY(), @> ARRAY[] = CONTAINS (EQUIVALENT TO ANY())
-- ----------------------------------------

-- Select the title and special features column 
SELECT 
	title, 
	special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[1] = 'Trailers';

-- Select the title and special features column 
SELECT 
	title, 
	special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';

SELECT
	  title, 
	  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = ANY (special_features);

SELECT 
	title, 
	special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];

-- ----------------------------------------
-- INTERVAL 'Text', AGE()
-- ----------------------------------------

SELECT
	rental_date,
	return_date,
-- Calculate the expected_return_date
	rental_date + INTERVAL '3 days' AS expected_return_date
FROM rental;


SELECT
	f.title,
-- Convert the rental_duration to an interval
	INTERVAL '1' day * f.rental_duration,
    r.return_date - r.rental_date AS days_rented
FROM film AS f
	INNER JOIN inventory AS i
		ON f.film_id = i.film_id
	INNER JOIN rental AS r
		ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
ORDER BY f.title;


SELECT
	f.title,
	r.rental_date,
	f.rental_duration,
-- Add the rental duration to the rental date
	INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
	r.return_date
FROM film AS f
    INNER JOIN inventory AS i
		ON f.film_id = i.film_id
    INNER JOIN rental AS r
		ON i.inventory_id = r.inventory_id
ORDER BY f.title;


SELECT f.title, f.rental_duration,
-- Calculate the number of days rented
	AGE(return_date, rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i
		ON f.film_id = i.film_id
	INNER JOIN rental AS r
		ON i.inventory_id = r.inventory_id
ORDER BY f.title;


SELECT
	f.title,
-- Convert the rental_duration to an interval
    INTERVAL '1' day * f.rental_duration,
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i
		ON f.film_id = i.film_id
    INNER JOIN rental AS r
		ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
ORDER BY f.title;

-- ----------------------------------------
-- CURRENT DATE / TIME
-- NOW(), CURRENT_DATE, CAST(... AS timestamp), CURRENT_TIMESTAMP, 
-- ----------------------------------------

-- Select the current timestamp
SELECT NOW();

-- Select the current date
SELECT CURRENT_DATE;

--Select the current timestamp without a timezone
SELECT CAST(NOW() AS timestamp);

SELECT 
-- Select the current date
	CURRENT_DATE,
-- CAST the result of the NOW() function to a date
	CAST(NOW() AS date);

--Select the current timestamp without timezone
SELECT CURRENT_TIMESTAMP::timestamp AS right_now;


SELECT
	CURRENT_TIMESTAMP::timestamp AS right_now,
	INTERVAL '5 days' + CURRENT_TIMESTAMP AS five_days_from_now;

SELECT
	CURRENT_TIMESTAMP(0)::timestamp AS right_now,
	INTERVAL '5 days' + CURRENT_TIMESTAMP(0) AS five_days_from_now;
	
-- ----------------------------------------
-- TRANSFORMING DATE/TIME DATA
-- EXTRACT(... FROM...), DATE_TRUNC()
-- ----------------------------------------

SELECT 
-- Extract day of week (DOW) from rental_date
	EXTRACT(DOW FROM rental_date) AS dayofweek 
FROM rental 
LIMIT 100;


SELECT 
	EXTRACT(DOW FROM rental_date) AS dayofweek, 
	COUNT(*) as rentals 
FROM rental 
GROUP BY 1;


-- Truncate rental_date by year
SELECT DATE_TRUNC('year', rental_date) AS rental_year
FROM rental;


SELECT 
	DATE_TRUNC('day', rental_date) AS rental_day,
	COUNT(*) AS rentals 
FROM rental
GROUP BY 1;

-- ----------------------------------------
-- MANIPULATING TEXT
-- CONCAT(), UPPER(), LOWER(), INITCAP(), REPLACE(), CHAR_LENGTH(), LEFT(), REVERSE(LEFT())
-- SUBSTRING(... FROM POSITION(... IN...) FOR ...)
-- RPAD(), LPAD(), TRIM()
-- ----------------------------------------
  
-- Concatenate the first_name and last_name and email 
SELECT first_name || ' ' || last_name || ' <' || email || '>' AS full_email 
FROM customer


-- Concatenate the first_name and last_name and email
SELECT CONCAT(first_name,' ', last_name,  ' <', email, '>') AS full_email 
FROM customer


SELECT 
-- Concatenate the category name to coverted to uppercase to the film title converted to title case
	UPPER(c.name)  || ': ' || INITCAP(f.title) AS film_category, 
	-- Convert the description column to lowercase
  LOWER(description) AS description
FROM 
	film AS f 
	INNER JOIN film_category AS fc 
		ON f.film_id = fc.film_id 
	INNER JOIN category AS c 
		ON fc.category_id = c.category_id;

SELECT 
	title,
	description,
-- Determine the length of the description column
	CHAR_LENGTH(description) AS desc_len
FROM film;


SELECT 
-- Select only the street name from the address table
	SUBSTRING(address FROM POSITION(' ' IN address)+1 FOR length(address))
FROM address;  


SELECT
-- Extract the characters to the left of the '@'
	LEFT(email, POSITION('@' IN email)-1) AS username,
-- Extract the characters to the right of the '@'
	SUBSTRING(email FROM POSITION('@' IN email)+1 FOR LENGTH(email)) AS domain
FROM customer;


-- Concatenate the padded first_name and last_name 
SELECT 
	RPAD(first_name, LENGTH(first_name)+1) || last_name AS full_name
FROM customer;


-- Concatenate the first_name and last_name 
SELECT 
	first_name || LPAD(last_name, LENGTH(last_name)+1) AS full_name
FROM customer; 


-- Concatenate the first_name and last_name 
SELECT 
	RPAD(first_name, LENGTH(first_name)+1) 
	|| RPAD(last_name, LENGTH(last_name)+2, ' <') 
	|| RPAD(email, LENGTH(email)+1, '>') AS full_email
FROM customer; 


-- Concatenate the uppercase category name and film title
SELECT 
	CONCAT(UPPER(c.name), ': ', f.title) AS film_category, 
-- Truncate the description remove trailing whitespace
	TRIM(LEFT(description, 50)) AS film_desc
FROM 
	film AS f 
	INNER JOIN film_category AS fc 
		ON f.film_id = fc.film_id 
	INNER JOIN category AS c 
		ON fc.category_id = c.category_id;


SELECT 
	UPPER(c.name) || ': ' || f.title AS film_category, 
-- Truncate the description without cutting off a word
	LEFT(description, 50 - 
-- Subtract the position of the first whitespace character
		POSITION(' ' IN REVERSE(LEFT(description, 50)))
		) 
FROM 
	film AS f 
	INNER JOIN film_category AS fc 
		ON f.film_id = fc.film_id 
	INNER JOIN category AS c 
		ON fc.category_id = c.category_id;

-- ----------------------------------------
-- FULL-TEXT SEARCH
-- LIKE, to_tsvector(), @@ tsquery(), 
-- ----------------------------------------

SELECT *
FROM film
-- Select only records that begin with the word 'GOLD'
WHERE title LIKE 'GOLD%';


SELECT *
FROM film
-- Select only records that end with the word 'GOLD'
WHERE title LIKE '%GOLD';


SELECT *
FROM film
-- Select only records that contain the word 'GOLD'
WHERE title LIKE '%GOLD%';


-- Select the film description as a tsvector
SELECT to_tsvector(description)
FROM film;


-- Select the title and description
SELECT title, description
FROM film
-- Convert the title to a tsvector and match it against the tsquery 
WHERE to_tsvector(title) @@ tsquery('elf');

-- ----------------------------------------
-- USER-DEFINED DATA TYPES AND FUNCTIONS
-- CREATE TYPE, ENUM
-- ENUM or enumerated data types are great options to use in your database when you have a column where you want to store a fixed list of values that rarely change.
-- ----------------------------------------

-- Create an enumerated data type, compass_position
CREATE TYPE compass_position AS ENUM ('North', 'South','East', 'West');


-- Confirm the new data type is in the pg_type system table
SELECT *
FROM pg_type
WHERE typname='compass_position';


-- Select the film title and inventory ids
SELECT 
	f.title, 
	i.inventory_id,
-- Determine whether the inventory is held by a customer
	inventory_held_by_customer(i.inventory_id) as held_by_cust
FROM film as f 
	INNER JOIN inventory AS i
		ON f.film_id=i.film_id 
WHERE
-- Only include results where the held_by_cust is not null
	inventory_held_by_customer(i.inventory_id) IS NOT NULL

-- ----------------------------------------
-- POSTGRES EXTENSIONS
-- CREATE EXTENSION IF NOT EXISTS, pg_trgm extension, fuzzystrmatch extension
-- similarity(), levenshtein() = the levenshtein distance represents the number of edits required to convert one string to another string being compared
-- ----------------------------------------

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;


-- Select all rows extensions
SELECT * 
FROM pg_extension;


SELECT 
	title, 
	description, 
-- Calculate the similarity
	similarity(title, description)
FROM film;
  

SELECT  
	title, 
	description, 
-- Calculate the levenshtein distance
	levenshtein(title, 'JET NEIGHBOR') AS distance
FROM film
ORDER BY 3;


SELECT 
	title, 
	description, 
-- Calculate the similarity
	similarity(description, 'Astounding Drama')
FROM film 
WHERE to_tsvector(description) @@ to_tsquery('Astounding & Drama') 
ORDER BY similarity(description, 'Astounding Drama') DESC;
