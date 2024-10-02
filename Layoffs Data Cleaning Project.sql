--Data cleaning
	-- 1.Remove Duplicates
	-- 2.Standardize the data
	-- 3.Null values or blank values
	-- 4.Remove any columns

SELECT * FROM layoffs;
SELECT * INTO layoffs_copy FROM layoffs;
SELECT * FROM layoffs_copy;

-- 1.Removing the duplicates

with cte as(
SELECT * , 
ROW_NUMBER() OVER(PARTITION BY company, location,industry,total_laid_off,percentage_laid_off, date,stage,country,funds_raised_millions ORDER BY company) as rn
FROM layoffs
)

DELETE FROM cte 
WHERE rn>1
;

SELECT * FROM layoffs 
WHERE company LIKE 'Cazoo'
;

SELECT * FROM layoffs ;

-- 2.Standardize the data

SELECT company, TRIM(company) FROM layoffs;

UPDATE layoffs 
SET company = TRIM(company)
;

SELECT DISTINCT industry FROM layoffs
ORDER BY industry;

UPDATE layoffs 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' 
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) FROM layoffs
ORDER BY country;

UPDATE layoffs 
SET country = TRIM(TRAILING '.' FROM country)
;

SELECT DISTINCT location FROM layoffs
ORDER BY location;

UPDATE layoffs 
SET location = 'Malmo'
WHERE location LIKE 'Malmö'
;

UPDATE layoffs 
SET location = 'Dusseldorf'
WHERE location LIKE 'Düsseldorf'
;

SELECT DISTINCT stage From layoffs
ORDER BY stage;

SELECT * FROM layoffs;


--3. Nulls and Blanks

SELECT * FROM layoffs 
WHERE industry IS NULL;

SELECT * FROM layoffs
WHERE company ='Airbnb'; 

UPDATE layoffs 
SET industry = 'Travel'
WHERE company = 'Airbnb' AND location = 'SF Bay Area' ; 

SELECT * FROM layoffs
WHERE company LIKE 'Bally%'; 

SELECT * FROM layoffs
WHERE company ='Juul'; 

UPDATE layoffs 
SET industry = 'Consumer'
WHERE company = 'Juul' AND location = 'SF Bay Area' ; 

SELECT * FROM layoffs
WHERE company ='Carvana'; 

UPDATE layoffs 
SET industry = 'Transportation'
WHERE company = 'Carvana' AND location = 'Phoenix' ; 

-- Another Method

UPDATE t1
SET t1.industry = t2. industry
FROM layoffs t1
INNER JOIN layoffs t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;


SELECT * FROM layoffs 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoffs 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT * FROM layoffs;