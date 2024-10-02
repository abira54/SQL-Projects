SELECT * FROM layoffs;

-- Max total laid off and percentage laid off

SELECT max(total_laid_off) as Max_laid_off, max(percentage_laid_off)as Max_per_laid_off FROM layoffs;


--Laid off duration

SELECT MIN(date) MIN_DATE, MAX(date) MAX_DATE FROM layoffs;

--Laid off with max percentage

SELECT * FROM layoffs
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

-- Total laid offs of company

SELECT company, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY company
ORDER BY t_laid_off DESC;

--Laid off by industry

SELECT industry, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY industry
ORDER BY t_laid_off DESC;

--Laid off by country

SELECT country, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY country
ORDER BY t_laid_off DESC;

--Laid offs by company in a year

SELECT company,  Year(date) as laid_year, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY company, Year(date)
ORDER BY company ;

-- Company year of Max total laid offs

SELECT company, sum(total_laid_off) as t_laid_off, Year(date) as laid_year
FROM layoffs
GROUP BY company, Year(date)
ORDER BY laid_year DESC ,t_laid_off DESC ;

-- Total laid off by date

SELECT date as laid_date, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY date
ORDER BY date DESC ;

--Total laid off by year

SELECT YEAR(date) as laid_year, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY YEAR(date)
ORDER BY YEAR(date) DESC ;

--Max laid off stage

SELECT stage, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY stage
ORDER BY t_laid_off DESC;

-- Avg of percentage_laid_off by company

SELECT company, AVG(percentage_laid_off) as per_laid_off
FROM layoffs
GROUP BY company
ORDER BY per_laid_off DESC;

-- Total laid offs by month

SELECT LEFT(date,7) as laid_month , sum(total_laid_off) as t_laid_off
FROM layoffs
WHERE LEFT(date,7) IS NOT NULL
GROUP BY LEFT(date,7)
ORDER BY laid_month;

--Rolling total by month

WITH rolling_total AS(
	SELECT LEFT(date,7) as laid_month , sum(total_laid_off) as t_laid_off
	FROM layoffs
	WHERE LEFT(date,7) IS NOT NULL
	GROUP BY LEFT(date,7)
)
SELECT laid_month ,t_laid_off, SUM(t_laid_off) OVER(ORDER BY laid_month) as rolling_total
FROM rolling_total
;

SELECT company, sum(total_laid_off) as t_laid_off
FROM layoffs
GROUP BY company
ORDER BY t_laid_off DESC;

-- Company ranking by year

WITH company_year AS(
	SELECT company,  Year(date) as years, sum(total_laid_off) as t_laid_off
	FROM layoffs
	GROUP BY company, Year(date)
),company_year_rank AS(
	SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY t_laid_off DESC) as ranking
	FROM company_year
	WHERE years IS NOT NULL
)
SELECT * FROM company_year_rank
WHERE ranking<6
;