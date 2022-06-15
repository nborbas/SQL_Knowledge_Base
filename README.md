# SQL Knowledge Base

In this repo, I'm sharing my notes from the [DataCamp](https://datacamp.com/) courses that I gathered during participation in the **SQL Fundemantals** and **SQL for Business Analysts** tracks.

## Content
- **0. Basic Functions** (based on course: Introduction to SQL)
  -  Aggregate functions (SUM, AVG, MIN, MAX)
  -  Introduction of below statements / functions (ABC order): AS, BETWEEN, GROUP BY, HAVING, LIKE & NOT LIKE, LIMIT, NULL & NOT NULL, ORDER BY, SELECT, WHERE
 
- **1. Joining Data** (based on course: Joining Data in SQL)
  - Joins (Inner, Left, Right, Outer (Full), Intersect, Except, Anti, Semi)
  - CASE-WHEN-THEN-ELSE-END
  - Basic Subqueries (in WHERE, FROM and SELECT statements)

- **2. Intermediate SQL** (based on course: Intermediate SQL)
  - CASE-WHEN-THEN-ELSE-END advanced
  - Subqueries (WHERE, FROM, SELECT, Correlated, Nested)
  - Common Table Expressions (CTE)
  - Window Functions (RANK, OVER, PARTITION BY, ROWS BETWEEN)

- **3. Aggregation & Window Functions** (based on course: PostgreSQL Summary Stats and Window Functions)
  - ROW_NUMBER()
  - LAG() & LEAD()
  - FIRST_VALUE() & LAST_VALUE()
  - Ranking: RANK() & DENSE_RANK()
  - Paging: NTILE()
  - Running Sums / Moving Calculations
  - Pivotting: CROSSTAB($$)
  - Subtotals: ROLLUP() & CUBE()
  - Handling NULL values: COALESCE()
  - String "aggregation": STRING_AGG()

- **4. Data Manipulation** (based on course: Functions for Manipulating Data in PostgreSQL)
  - System Databases (information_schema.tables, information_schema.columns,
  - Arrays (ANY(), ARRAY[ ]) 
  - Date / Time: INTERVAL, AGE(), NOW(), CURRENT_DATE, CURRENT_TIMESTAMP, EXTRACT( FROM ), DATE_TRUNC()
  - Text Manipulation: CONCAT(), UPPER(), LOWER(), INITCAP(), REPLACE(), CHAR_LENGTH(), LEFT(), REVERSE(LEFT()), SUBSTRING( FROM POSITION( IN ) FOR ), RPAD(), LPAD(), TRIM()
  - Text Search: LIKE, NOT LIKE, TO_TSVECTOR(), @@ TSQUERY()
  - User-defined Data Types: CREATE TYPE, ENUM()
  - Postgres Extensions: pg_trgm, fuzzystrmatch
  - Postgres Extensions statements/clauses: CREATE EXTENSION IF NOT EXISTS, SIMILARITY(), LEVENSHTEIN()

- **5. Exploratory Data Analysis (EDA)** (based on course: Exploratory Data Analysis in SQL)
  - Identifying missing data
  - Foreign keys
  - Handling NULL values: COALESCE()
  - Change Data Type: CAST()
  - Distribution, Generating Bins: TRUNC(), GENERATE_SERIES()
  - Aggregating Data: MIN(), AVG(), MAX(), STDDEV(), CORR(), PERCENTILE_DISC() WITHIN GROUP (ORDER BY )
  - Creating a TEMP Table: DROP TABLE IF EXISTS, CREATE TEMP TABLE AS, INSERT INTO, UPDATE, SET
  - Counting Categories
  - Working with unstructured text: TRIM(), LTRIM(), RTRIM(), LIKE, ILIKE, CONCAT(), SPLIT_PART()
  - Shorten Long Strings
  - Date/Time Types and Formats: "::interval", DATE_PART(), TO_CHAR(), EXTRACT( FROM ), DATE_TRUNC(), GENERATE_SERIES(), LAG() OVER (ORDER BY ), LEAD() OVER (ORDER BY )

- **6. Grouping & Nested Queries** (based on course: Data-Driven Decision Making in SQL)
  - XXX
  - XXX
  - XXX

- **7. Real World SQL** (based on course: Applying SQL to Real-World Problems)
  - XXX
  - XXX
  - XXX

- **8. Business Data Analysis** (based on course: Analyzing Business Data in SQL)
  - XXX
  - XXX
  - XXX

- **9. Data Reporting** (based on course: Reporting in SQL)
  - XXX
  - XXX
  - XXX
