-- ----------------------------------------
-- CASE-WHEN-THEN-ELSE-END
-- ----------------------------------------

-- Identify the home team as Bayern Munich, Schalke 04, or neither
SELECT 
	CASE WHEN hometeam_id = 10189 THEN 'FC Schalke 04'
       WHEN hometeam_id = 9823 THEN 'FC Bayern Munich'
       ELSE 'Other' END AS home_team,
	COUNT(id) AS total_matches
FROM matches_germany
GROUP BY home_team;

-- Using CASE statements with joins
SELECT 
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal > away_goal THEN 'Barcelona win!'
        WHEN m.home_goal < away_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.awayteam_id = t.team_api_id
WHERE m.hometeam_id = 8634; 

-- Complex CASE statements
SELECT 
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
       ELSE 'Real Madrid CF' END as home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
       ELSE 'Real Madrid CF' END as away,
	CASE WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win!'
       WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win!'
       WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win!'
       WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win!'
       ELSE 'Tie!' END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);
      
-- CASE statement in WHERE - using as exclusion
SELECT *
FROM table
WHERE 
    CASE WHEN a > 5 THEN 'Keep'
         WHEN a <= 5 THEN 'Exclude' END = 'Keep';
         
-- Select the season, date, home_goal, and away_goal columns
SELECT 
	season,
  date,
	home_goal,
	away_goal
FROM matches_italy
WHERE 
	CASE WHEN hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
		   WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win' 
		   END IS NOT NULL;
       
-- Using aggregates in CASE
SELECT 
	c.name AS country,
	COUNT (CASE WHEN m.season = '2012/2013' THEN m.id END) AS matches_2012_2013,
	COUNT(CASE WHEN m.season = '2013/2014' THEN m.id END) AS matches_2013_2014,
	COUNT(CASE WHEN m.season = '2014/2015' THEN m.id END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
  ON c.id = m.country_id
GROUP BY c.name;

SELECT 
	c.name AS country,
    -- Sum the total records in each season where the home team won
	SUM(CASE WHEN m.season = '2012/2013' AND m.home_goal > m.away_goal 
           THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal 
           THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal
           THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
  ON c.id = m.country_id
GROUP BY c.name;

-- Calculation percentage information with CASE
AVG(CASE WHEN condition_is_met THEN 1
         WHEN condition_is_not_met THEN 0 END)
         
SELECT 
	c.name AS country,
	AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			END) AS ties_2013_2014,
	AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			END) AS ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
  ON c.id = m.country_id
GROUP BY country;

-- ----------------------------------------
-- SUBQUERIES IN WHERE STATEMENT
-- ----------------------------------------

-- Filter where goal score is higher than 3x of average
SELECT 
  date,
	home_goal,
	away_goal
FROM  matches_2013_2014
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 

-- Excluding home teams
SELECT 
	team_long_name,
	team_short_name
FROM team
WHERE team_api_id NOT IN
     (SELECT DISTINCT hometeam_id  FROM match);
     
-- ----------------------------------------
-- SUBQUERIES IN FROM STATEMENT
-- ----------------------------------------

-- A subquery in FROM is an effective way of answering detailed questions that requires filtering or transforming data before including it in your final results.
SELECT
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
INNER JOIN (SELECT country_id, id
           FROM match
           WHERE (home_goal + away_goal) >= 10) AS sub
  ON c.id = sub.country_id
GROUP BY country_name;

-- The full statement in FROM is treated as 1 single table
SELECT
    country,
    date,
    home_goal,
    away_goal
FROM 
	(SELECT c.name AS country, 
     	    m.date, 
     	   	m.home_goal, 
     		  m.away_goal,
          (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
      ON m.country_id = c.id) AS subq
WHERE total_goals >= 10;

-- ----------------------------------------
-- SUBQUERIES IN SELECT STATEMENT
-- ----------------------------------------

-- Subqueries in SELECT statements generate a single value that allow you to pass an aggregate value down a data frame
SELECT 
	l.name AS league,
  ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
  (SELECT ROUND(AVG(home_goal + away_goal), 2) 
   FROM match
   WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
  ON l.country_id = m.country_id
WHERE season = '2013/2014'
GROUP BY league;

-- Can be used for calculating difference for example
SELECT
	l.name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
	ROUND(AVG(m.home_goal + m.away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
     WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
  ON l.country_id = m.country_id
WHERE season = '2013/2014'
GROUP BY l.name;

-- ----------------------------------------
-- CORRELATED SUBQUERIES
-- ----------------------------------------

/* Correlated subqueries are subqueries that reference one or more columns in the main query.
   Correlated subqueries depend on information in the main query to run, and thus, cannot be executed on their own.*/

SELECT 
	  main.country_id,
    main.date,
    main.home_goal, 
    main.away_goal
FROM match AS main
WHERE 
	(home_goal + away_goal) > 
        (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
         FROM match AS sub
         WHERE main.country_id = sub.country_id);
         
-- ----------------------------------------
-- NESTED SUBQUERIES
-- ----------------------------------------

-- Can be simple and correlated subquery
SELECT
	season,
    MAX(home_goal + away_goal) AS max_goals,
   (SELECT MAX(home_goal + away_goal) FROM match) AS overall_max_goals,
   (SELECT MAX(home_goal + away_goal) 
    FROM match
    WHERE id IN (
          SELECT id FROM match WHERE EXTRACT(MONTH FROM date) = 07)) AS july_max_goals
FROM match
GROUP BY season;

SELECT
	c.name AS country,
	AVG(outer_s.matches) AS avg_seasonal_high_scores
FROM country AS c
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS inner_s
  GROUP BY country_id, season) AS outer_s
ON c.id = outer_s.country_id
GROUP BY country;

-- ----------------------------------------
-- COMMON TABLE EXPRESSIONS (CTE)
-- ----------------------------------------

-- Define CTE: WITH 'table name' AS (query)
WITH match_list AS (
    SELECT 
  		country_id, 
  		id
    FROM match
    WHERE (home_goal + away_goal) >= 10)

SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM league AS l
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

-- CTE works with Nested Subqueries
WITH match_list AS (
    SELECT 
  		country_id,
  	  (home_goal + away_goal) AS goals
    FROM match
    WHERE id IN (
       SELECT id
       FROM match
       WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = 8))

SELECT 
	l.name,
    AVG(goals)
FROM league AS l
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

-- ----------------------------------------
-- WINDOW FUNCTIONS
-- STATEMENTS: OVER(), RANK() OVER(ORDER BY ...), OVER(PARTITION BY...)
--             OVER(ORDER BY... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), OVER(ORDER BY... ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
-- ----------------------------------------

-- Use OVER() to include the aggregate average in each row
SELECT 
	m.id, 
  c.name AS country, 
  m.season,
	m.home_goal,
	m.away_goal,
	AVG(m.home_goal + m.away_goal) OVER() AS overall_avg
FROM match AS m
LEFT JOIN country AS c ON m.country_id = c.id;

-- Ranking with RANK()
SELECT 
    id,
    RANK() OVER(ORDER BY home_goal) AS rank
FROM match;

-- The PARTITION BY clause allows you to calculate separate "windows" based on columns you want to divide your results. 
SELECT
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home' 
		   ELSE 'away' END AS warsaw_location,
   AVG(home_goal) OVER(PARTITION BY season) AS season_homeavg,
   AVG(away_goal) OVER(PARTITION BY season) AS season_awayavg
FROM match
WHERE 
	hometeam_id = 8673 
  OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;

-- Running calculations
SELECT 
	date,
	home_goal,
	away_goal,
  SUM(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
   AVG(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE 
	hometeam_id = 9908 
	AND season = '2011/2012';

SELECT 
	  date,
    home_goal,
    away_goal,
    SUM(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
    AVG(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE 
	awayteam_id = 9908 
  AND season = '2011/2012';
  
-- All together
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		     WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),

away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
		   WHEN m.home_goal < m.away_goal THEN 'MU Win' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)

SELECT DISTINCT
    date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, m.away_goal,
    RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) as match_rank
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));
