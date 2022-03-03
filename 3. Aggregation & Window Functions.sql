-- ----------------------------------------
-- WINDOW FUNCTIONS
-- ----------------------------------------

-- ----------------------------------------
-- ROW_NUMBER() OVER(ORDER BY ...)
-- ----------------------------------------

  -- Assign numbers to each row
SELECT
  *,
  ROW_NUMBER() OVER() AS Row_N
FROM Medals
ORDER BY Row_N ASC;

  -- Assign the lowest numbers to the most recent years
SELECT
  Year,
  ROW_NUMBER() OVER (ORDER BY Year DESC) AS Row_N
FROM (
  SELECT DISTINCT Year
  FROM Medals
) AS Years
ORDER BY Year;

-- Count the number of medals each athlete has earned, then number them
WITH Athlete_Medals AS (
  SELECT
    Athlete,
    COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete)

SELECT
  Athlete, 
  ROW_NUMBER() OVER (ORDER BY Medals DESC) AS Row_N
FROM Athlete_Medals
ORDER BY Medals DESC;

-- ----------------------------------------
-- LAG(...) OVER(PARTITION BY ... ORDER BY ...)
-- ----------------------------------------

-- Last champion with LAG()
SELECT
  Year, Champion,
  LAG(Champion) OVER
    (ORDER BY Year ASC) AS Last_Champion
FROM Gold
ORDER BY Year ASC;

-- Partitioning by Gender
SELECT
  Gender, Year, Event,
  Country AS Champion,
  LAG(Country) OVER (PARTITION BY gender, event
            ORDER BY Year ASC) AS Last_Champion
FROM Gold 
ORDER BY Event ASC, Gender ASC, Year ASC;

-- ----------------------------------------
-- LEAD(...) OVER(PARTITION BY ... ORDER BY ...)
-- ----------------------------------------

  -- For each year, fetch the current and future medalists
SELECT
  year,
  athlete,
  LEAD(athlete,3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Medalists
ORDER BY Year ASC;

SELECT
  athlete,
  FIRST_VALUE(athlete) OVER (
    ORDER BY athlete ASC
  ) AS First_Athlete
FROM All_Male_Medalists;

-- ----------------------------------------
-- FIRST_VALUE(...) OVER(ORDER BY ...)
-- LAST_VALUE(...) OVER(ORDER BY ... RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
-- ----------------------------------------

-- Fetch all athletes and the first athlete alphabetically
SELECT
  athlete,
  FIRST_VALUE(athlete) OVER (
    ORDER BY athlete ASC
  ) AS First_Athlete
FROM All_Male_Medalists;

-- Get the last city in which the Olympic games were held
SELECT
  Year,
  City,
  LAST_VALUE(City) OVER (
   ORDER BY Year ASC
   RANGE BETWEEN
     UNBOUNDED PRECEDING AND
     UNBOUNDED FOLLOWING
  ) AS Last_City
FROM Hosts
ORDER BY Year ASC;

-- ----------------------------------------
-- RANKING:
-- RANK(...) OVER(PARTITION BY... ORDER BY ...)
-- DENSE_RANK(...) OVER(PARTITION BY... ORDER BY ...)
-- ----------------------------------------

-- Rank athletes by the medals they've won
SELECT
  Athlete,
  Medals,
  RANK() OVER (ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Medals DESC;

-- Rank athletes in each country by the medals they've won
SELECT
  Country,
  Athlete,
  DENSE_RANK() OVER (PARTITION BY Country
                ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, RANK_N ASC;

-- ----------------------------------------
-- PAGING:
-- NTILE(...) OVER(ORDER BY...)
-- ----------------------------------------

-- Split up the distinct events into 11 unique groups
SELECT
  Event,
  NTILE(11) OVER (ORDER BY Event ASC) AS Page
FROM Events
ORDER BY Event ASC;

-- Split athletes into thirds by their earned medals
SELECT
  Athlete,
  Medals,
  NTILE(3) OVER (ORDER BY Medals DESC) AS Third
FROM Athlete_Medals
ORDER BY Medals DESC, Athlete ASC;

-- ----------------------------------------
-- RUNNING SUM / MIN / MAX CALCULATIONS
-- SUM/MIN/MAX(...) OVER(PARTITION BY... ORDER BY...)
-- ----------------------------------------

-- Calculate the running total of athlete medals
SELECT
  athlete,
  medals,
  SUM(medals) OVER (ORDER BY athlete ASC) AS Max_Medals
FROM Athlete_Medals
ORDER BY Athlete ASC;

-- Return the max medals earned so far per country
SELECT
  year,
  country,
  medals,
  MAX(medals) OVER (PARTITION BY country
                ORDER BY year ASC) AS Max_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

-- ----------------------------------------
-- FRAMES / MOVING CALCULATIONS
-- E.G.: MAX(...) OVER(ORDER BY... ROWS BETWEEN CURRENT ROWM AND 1 FOLLOWING)
-- ----------------------------------------

-- Get the max of the current and next years'  medals
SELECT
  Year,
  Medals,
  MAX(Medals) OVER (ORDER BY Year ASC
             ROWS BETWEEN CURRENT ROW
             AND 1 FOLLOWING) AS Max_Medals
FROM Medals
ORDER BY Year ASC;

-- Get the max of the last two and current rows' medals 
SELECT
  Athlete,
  Medals,
  MAX(Medals) OVER (ORDER BY Athlete ASC
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW) AS Max_Medals
FROM Chinese_Medals
ORDER BY Athlete ASC;

-- Calculate the 3-year moving average of medals earned
SELECT
  Year, Medals,
  AVG(Medals) OVER
    (ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_Avg
FROM Medals
ORDER BY Year ASC;

-- Calculate each country's 3-game moving total
SELECT
  Year, Country, Medals,
  SUM(Medals) OVER
    (PARTITION BY Country
     ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

-- ----------------------------------------
-- PIVOTTING
-- CROSSTAB($$ ... $$)
-- ----------------------------------------

-- Create the correct extention to enable CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Pole Vault'
  ORDER By Gender ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Gender VARCHAR,
           "2008" VARCHAR,
           "2012" VARCHAR)

ORDER BY Gender ASC;


-- Pivotting including a CTE and a Window Function
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  WITH Country_Awards AS (
    SELECT
      Country,
      Year,
      COUNT(*) AS Awards
    FROM Summer_Medals
    WHERE
      Country IN ('FRA', 'GBR', 'GER')
      AND Year IN (2004, 2008, 2012)
      AND Medal = 'Gold'
    GROUP BY Country, Year)

  SELECT
    Country,
    Year,
    RANK() OVER
      (PARTITION BY Year
       ORDER BY Awards DESC) :: INTEGER AS rank
  FROM Country_Awards
  ORDER BY Country ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Country VARCHAR,
           "2004" INTEGER,
           "2008" INTEGER,
           "2012" INTEGER)

Order by Country ASC;

-- ----------------------------------------
-- ROLLUP() AND CUBE()
-- NOTE: ~Subtotals
-- ----------------------------------------

-- Generate Country-level subtotals (GROUP BY statement)
SELECT
  Country,
  Gender,
  COUNT(*) AS Gold_Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
GROUP BY Country, ROLLUP(Gender)
ORDER BY Country ASC, Gender ASC;

-- Get all possible group-level subtotals (GROUP BY statement)
SELECT
  Gender,
  Medal,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2012
  AND Country = 'FRA'
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender ASC, Medal ASC;

-- ----------------------------------------
-- COALESCE()
-- NOTE: Used for cleaning up NULL values
-- ----------------------------------------

  -- Replace the nulls in the columns with meaningful text
SELECT
  COALESCE(Country, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
GROUP BY ROLLUP(Country, Gender)
ORDER BY Country ASC, Gender ASC;

-- ----------------------------------------
-- STRING_AGG()
-- NOTE: Output county names by comma and 1 line
-- ----------------------------------------

-- Compress the countries column
SELECT STRING_AGG(Country, ', ')
FROM Country_Ranks
WHERE Rank <=3;
