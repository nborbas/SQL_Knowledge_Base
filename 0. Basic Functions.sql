-- ----------------------------------------
-- BASIC FUCNTIONS
-- ----------------------------------------

SELECT title
FROM films;

SELECT DISTINCT country
FROM films;

SELECT COUNT(*)
FROM people;

SELECT title
FROM films
WHERE title = 'Metropolis';

SELECT title
FROM films
WHERE release_year > 2000;

-- Select all items
SELECT *
FROM films
WHERE release_year = 2016;

-- AND
SELECT title, release_year
FROM films
WHERE language = 'Spanish'
AND release_year < 2000;

-- OR
SELECT title
FROM films
WHERE release_year = 1994 OR 2000;

-- BETWEEN
SELECT name
FROM people
WHERE income BETWEEN 10000 AND 50000
  AND nationality = 'USA';
  
-- IN
SELECT name
FROM kids
WHERE age IN (2, 4, 6, 8, 10);

-- LIKE
SELECT name
FROM people
WHERE name LIKE 'B%'; -- % replaces many characters

SELECT name
FROM people
WHERE name LIKE '_r%'; -- _ replaces only one character

-- IS NULL & IS NOT NULL
SELECT COUNT(*)
FROM people
WHERE birthdate IS NULL; -- Could be IS NOT NULL

-- AS + basic arithmetic: +, -, *, /
SELECT (4/3) AS result; -- Results in integer 1
SELECT (4.0/3.0) AS result; -- Results in float 1.333

-- Selecting sum, average, maximum and minimum
SELECT SUM(budget), AVG(budget), MAX(budget), MIN(budget)
FROM films;

-- ORDER BY
SELECT name
FROM people
ORDER BY name;

SELECT title
FROM films
WHERE release_year IN (2000, 2012)
ORDER BY release_year DESC;

-- GROUP BY
SELECT sex, count(*)
FROM employees
GROUP BY sex;

-- HAVING - similar to WHERE statement, needed when the result is an aggregate function
SELECT release_year
FROM films
GROUP BY release_year
HAVING COUNT(title) > 10;

-- All together
SELECT country, AVG(budget) AS avg_budget, AVG(gross) AS avg_gross
FROM films
GROUP BY country
HAVING COUNT(title) > 10
ORDER BY country
LIMIT 5;
