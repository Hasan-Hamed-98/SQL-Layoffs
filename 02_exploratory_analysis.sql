-- Exploratory Data Analysis
-- world_layoffs database







SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


-- Companies that laid off all their employees
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;


-- Companies with the highest numbers of laid off employees
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- Amazon, Google, and Meta had the highest numbers of
-- laid off employees over the span of 3 years
-- March/2020 >>> March/2023


-- industries with the highest numbers of laid off employees
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- Consumer, Retail, and Transportation had the highest numbers
-- of laid off employees over the span of 3 years
-- March/2020 >>> March/2023


-- Countries with the highest numbers of laid off employees
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- United States, India, and Netherlands had the highest numbers
-- of laid off employees over the span of 3 years
-- March/2020 >>> March/2023


SELECT DISTINCT MONTH(`date`) AS `month`
FROM layoffs_staging2
WHERE MONTH(`date`) IS NOT NULL
ORDER BY 1;


-- A rolling total based on months
WITH Rolling_Total AS
(
SELECT
	SUBSTRING(`date`, 1, 7) AS `month`,
	SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month` ASC
)
SELECT
	`month`,
    total_off,
	SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;
-- The rolling total shows the highest numbers of laid off employees
-- were Oct/2022 >>> Feb/2023



SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


WITH company_years (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
), company_year_rank AS
(
SELECT *, 
DENSE_RANK()OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_years
WHERE years IS NOT NULL
ORDER BY ranking ASC
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;

-- looking at the companies that had the highest numbers of laid off
--  employees each year
-- 2020: Uber with 7525 employees laid off,
-- 2021: Bytedance with 3600 employees laid off,
-- 2022: Meta with 11000 employees laid off,
-- 2023: Google with 12000 employees laid off.



