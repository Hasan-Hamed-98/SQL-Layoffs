-- Data Cleaning Project
-- world_layoffs database


-- Roadmap

-- Step 1: Create layoffs_staging table
-- so we don't alter the raw data if we make any mistakes

-- Step 2: Remove duplicates
-- Since there isn't an identifying column, I'll use
-- a ROW_NUMBER column to identify and remove duplicates

-- Step 3: Stanardize data
	-- Section 1: Trimming companies names with spaces
	-- Section 2: Fixing multiple variants of Crypto industry
	-- 			  in the industry column
	-- Section 3: Fixing an issue where United States. has a period
	-- 			  in the country table
	-- Section 4: Altering the date column's variable type from
	-- 			  string to date

-- Step 4: Null values or blank values
-- populating data in industry column using other records
-- for the same companies



-- Step 5: Remove any rows or columns
-- Section 1: Removing records where total_laid_off is null
-- 			  and percentage_laid_off is null
-- Section 2: Removing the row_num column we added at the start

-- ----------------------------------------------------------------------


-- Step 1: Create layoffs_staging table

SELECT *
FROM layoffs;


CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging;


INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


SELECT *
FROM layoffs_staging;

-- ----------------------------------------------------------------------


-- Step 2: Remove Duplicates

SELECT *
FROM layoffs_staging;


SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- Any row with row_number > 1 is a duplicate row


-- Creating the command as a CTE to make it easier to call and use
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- We have duplicate rows with companies
-- (Casper, Cazoo, Hibob, Yahoo, Wildlife Studios)


-- Checking some of the duplicate rows
SELECT *
FROM layoffs_staging
WHERE company LIKE '%Casper%';


-- Creating layoffs_staging2 table, which is the same as
-- layoffs_staging but with extra row_num column
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


DELETE FROM layoffs_staging2
WHERE row_num > 1;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- duplicate rows are now removed

-- ----------------------------------------------------------------------


-- Step 3: Stanardize data

-- Section 1: Trimming companies names with spaces

-- Looking for company names with spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;
-- The TRIM column looks better


UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT company, TRIM(company)
FROM layoffs_staging2;
-- 11 rows were changed and companies names are without spaces


-- Looking at industries
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- I noticed that there are Null values, blank values,
-- (Crypto, Crypto Currency, CryptoCurrency) values which
-- are the same thing



-- Section 2: Fixing multiple variants of Crypto industry
-- 			  in the industry column

SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';


SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';
-- Now all the rows with Crypto industry are labeled Crypto


--  Checking...
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


-- Scanning for issues in location column
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;
-- Found some weird locations (MalmÃ¶, DÃ¼sseldorf, FlorianÃ³polis)
-- maybe it's another language. I'll leave them for now.


-- Scanning for issues in country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
-- Found an issue (United States, United States.)
-- United States is with a period at the end




-- Section 3: Fixing an issue where United States. has a period
-- 			  in the country table

SELECT *
FROM layoffs_staging2
WHERE country LIKE '%united states%';


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%United States%';
-- United States is now the same across all records




-- Section 4: Altering the date column's variable type from
-- 			  string to date

-- Looking at the date column
-- the date column is set to a string type variable
-- which is not ideal

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- Now date column has dates in standard date format


-- Now to alter the variable type for date column
-- from string to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ----------------------------------------------------------------------


-- Step 4: Null values or blank values

-- Checking for null and blank values
SELECT *
FROM layoffs_staging2;
-- Noticed that some of the total_laid_off and percerntage_laid_off
-- values are null or blank.
-- Noticed that some industry values are null or blank.


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;


SELECT DISTINCT industry
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
	OR industry = '';
-- Found records with null or blank industry values with
-- companies names (Airbnb, Bally's Interactive, Carvana, Juul)



-- Section 1: Trying to populate data in industry column
-- 			  using other records

SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Airbnb%';
-- Found another record for the same company Airbnb; where 
-- industry is set to Travel.


-- Using a SELF JOIN to find records where company name is the same.
-- One of them has null or blank industry, and the other doesn't.
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
	AND (t2.industry IS NOT NULL AND t2.industry != '');
-- Found records for Airbnb, Carvana, Juul companies where
-- one of them has null or blank industry and the others state
-- an industry.
-- We can populate the null or blank industries using
-- those other records


UPDATE layoffs_staging2 t1
	JOIN layoffs_staging2 t2
		ON t1.company = t2.company
		AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
	AND (t2.industry IS NOT NULL AND t2.industry != '');
-- Records were successfully populated!


SELECT *
FROM layoffs_staging2
WHERE company LIKE "%Bally's Interactive%";
-- there aren't any other records for Bally's Interactive


-- Note: there is no enough info to populate null values in columns
-- like total_laid_off, percentage_laid_off. 

-- ----------------------------------------------------------------------


-- Step 5: Remove any rows or columns

-- Section 1: Given the nature of the data, I reckon that
-- records with no info about total_laid_off and percentage_laid_off
--  will be useless in analysis

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;


DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;




-- Section 2: Removing the row_num column I added at the start
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT *
FROM layoffs_staging2;







