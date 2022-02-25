-- ----------------------------------------
-- INNER JOIN
-- ----------------------------------------

-- Basic syntax
SELECT c1.name AS city, c2.name AS country
FROM cities AS c1
INNER JOIN countries AS c2
  ON c1.country_code = c2.code;

-- Tables with common key fields
SELECT *
FROM countries
INNER JOIN economies
  USING(code);

-- ----------------------------------------
-- CASE-WHEN-THEN-ELSE-END
-- ----------------------------------------

SELECT name, continent, code, surface_area,
CASE WHEN surface_area > 2000000 THEN 'large'
     WHEN surface_area < 350000 THEN 'small'
     ELSE 'medium' END
     AS geosize_group
FROM countries;

-- Create new table with INTO
SELECT name, continent, code, surface_area,
    CASE WHEN surface_area > 2000000
            THEN 'large'
       WHEN surface_area > 350000
            THEN 'medium'
       ELSE 'small' END
       AS geosize_group
INTO countries_plus
FROM countries;


-- ----------------------------------------
-- LEFT-RIGHT JOINS
-- ----------------------------------------

SELECT name, region
FROM countries AS c
LEFT JOIN economies AS e
  ON c.code = e.code
WHERE year = 2010;

SELECT cities.name AS city, countries.name AS country, languages.name AS language,
FROM languages
RIGHT JOIN countries
  ON languages.code = countries.code
RIGHT JOIN cities
  ON countries.code = cities.country_code
ORDER BY city, language;

-- ----------------------------------------
-- FULL JOINS = OUTER JOINS
-- ----------------------------------------

SELECT name AS country, code
FROM countries
FULL JOIN currencies
  USING (code)
WHERE region = 'North America'
ORDER BY region;

-- ----------------------------------------
-- CROSS JOINS
-- ----------------------------------------

SELECT c.name AS city, l.name AS language
FROM cities AS c        
CROSS JOIN languages AS l
WHERE c.name LIKE 'Hyder%';

-- ----------------------------------------
-- UNIONS & INTERSECT & EXCEPT
-- ----------------------------------------

-- UNION to remove duplicates
SELECT *
FROM economies2010
  UNION
SELECT *
FROM economies2015
ORDER BY code, year;

-- UNION ALL to include duplicates
SELECT *
FROM economies2010
  UNION ALL
SELECT *
FROM economies2015
ORDER BY code, year;

-- Common records
SELECT code, year
FROM economies
  INTERSECT
SELECT country_code, year
FROM populations
ORDER BY code, year;

-- Excluding values that are in the other table

SELECT name
FROM cities
	EXCEPT
SELECT capital
FROM countries
ORDER BY name;


-- ----------------------------------------
-- SEMI JOINS & ANTI JOINS (FILTERING JOINS)
-- ----------------------------------------

SELECT DISTINCT name
FROM languages
WHERE code IN
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
ORDER BY name;


SELECT code, name
FROM countries
WHERE continent = 'Oceania'
  AND code NOT IN
  	(SELECT code
  	 FROM currencies);


-- ----------------------------------------
-- SUBQUERY IN WHERE, SELECT, FROM
-- ----------------------------------------

-- WHERE clause
SELECT cities.name, cities.country_code, urbanarea_pop
  FROM cities
WHERE cities.name IN
  (SELECT capital
   FROM countries)
ORDER BY urbanarea_pop DESC;

-- SELECT clause
SELECT countries.name AS country, 
    (SELECT COUNT(*)
    FROM cities
    WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country;

-- FROM clause
SELECT local_name, lang_num
FROM countries,
  	(SELECT languages.code, COUNT (name) AS lang_num
  	 FROM languages
  	 GROUP BY code) AS subquery
WHERE countries.code = subquery.code
ORDER BY lang_num DESC;

-- All together
SELECT name, country_code, city_proper_pop, metroarea_pop,  
FROM cities
WHERE name IN
    (SELECT capital
     FROM countries
     WHERE (continent = 'Europe' OR continent LIKE '%America%'))
AND metroarea_pop IS NOT NULL
ORDER BY name DESC
LIMIT 10;
