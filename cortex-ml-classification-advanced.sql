-- Train data set
SELECT * FROM KAGGLE.PUBLIC.TITANIC_TRAIN;

-- Let's find out the median age (=28.0)
-- I also tested different median ages for males and females, but it was worse.
SELECT MEDIAN(AGE) FROM TITANIC_TRAIN WHERE AGE IS NOT NULL;

-- Let's find out the median age per sex (=27.0 for females, 29.0 for males)
SELECT MEDIAN(AGE), SEX FROM TITANIC_TRAIN WHERE AGE IS NOT NULL GROUP BY SEX;

-- Let's find the MEAN age (29,7)
SELECT AVG(AGE) FROM TITANIC_TRAIN WHERE AGE IS NOT NULL;


-- Let's see how much % of people survived (342/891 -> 38,38%)
SELECT COUNT(*) AS COUNT, SURVIVED FROM TITANIC_TRAIN GROUP BY SURVIVED;

-- Let's see how much % of dr.'s survived (3/7 -> 42,9%)
-- We are going to add this as one of the titles
SELECT COUNT(SURVIVED) AS COUNT, SURVIVED FROM TITANIC_TRAIN WHERE LOWER(NAME) LIKE '%dr.%' GROUP BY SURVIVED;

-- Let's presume people younger than 15 and older than 60 needs help. First, let's check how many of survived (=50%)
-- I tried to add this feature but doesn't help much (worse score)
SELECT COUNT(SURVIVED) AS COUNT, SURVIVED FROM TITANIC_TRAIN WHERE AGE < 15 OR AGE > 60 GROUP BY SURVIVED;

SELECT 
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss'
        WHEN LOWER(NAME) LIKE '%ms.%' THEN 'ms'
        WHEN LOWER(NAME) LIKE '%col.%' THEN 'col'
        WHEN LOWER(NAME) LIKE '%rev.%' THEN 'rev'
        WHEN LOWER(NAME) LIKE '%dona.%' THEN 'dona'
        ELSE 'none'
    END AS TITLE,
    COUNT(*) AS COUNT
FROM TITANIC_TEST
GROUP BY TITLE;

SELECT 
    MAX(FARE) AS MAX_FARE,
    MIN(FARE) AS MIN_FARE,
    AVG(FARE) AS AVG_FARE,
    MEDIAN(FARE) AS MEDIAN_FARE
FROM TITANIC_TRAIN
WHERE FARE IS NOT NULL;

-- Let's find out quartiles (7.9104, 14.4542, 31.0)
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY COALESCE(FARE, 0)) AS FIRST_QUARTILE,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY COALESCE(FARE, 0)) AS MID,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY COALESCE(FARE, 0)) AS THRIRD_QUARTILE
FROM TITANIC_TRAIN

-- Let's validate the quartiles by counting people put into the tiers (TIER 1 - 4)
SELECT 
    CASE 
        WHEN FARE < 7.9104 THEN 'TIER1'
        WHEN FARE >= 7.9104 AND FARE < 14.4542 THEN 'TIER2'
        WHEN FARE >= 14.4542 AND FARE < 31.0 THEN 'TIER3'
        ELSE 'TIER4'
    END AS TIER,
    COUNT(TIER) AS COUNT
FROM TITANIC_TRAIN
GROUP BY TIER
ORDER BY TIER
    

CREATE OR REPLACE VIEW titanic_train_advanced AS
SELECT 
    --CABIN, 
    --NAME,
    PASSENGERID,
    SURVIVED,
    PCLASS,
    SEX,
    CASE 
        WHEN AGE IS NULL THEN 28.0 ELSE AGE
    END AS AGE,
    SIBSP,
    PARCH,
    FARE,
    --CASE 
    --    WHEN FARE < 7.9104 THEN 'TIER1'
    --    WHEN FARE >= 7.9104 AND FARE < 14.4542 THEN 'TIER2'
    --    WHEN FARE >= 14.4542 AND FARE < 31.0 THEN 'TIER3'
    --    ELSE 'TIER4'
    --END AS FARE_TIER,
    TICKET,
    EMBARKED,
    CASE
        WHEN (SIBSP + PARCH) BETWEEN 1 AND 3 THEN 'SMALL'
        WHEN (SIBSP + PARCH) BETWEEN 4 AND 5 THEN 'MEDIUM'
        WHEN (SIBSP + PARCH) > 6 THEN 'LARGE'
    ELSE 'ALONE'
    END AS FAMILY_SIZE,
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss'
        WHEN LOWER(NAME) LIKE '%ms.%' THEN 'ms'
        --WHEN LOWER(NAME) LIKE '%col.%' THEN 'col'
        --WHEN LOWER(NAME) LIKE '%rev.%' THEN 'rev'
        --WHEN LOWER(NAME) LIKE '%dona.%' THEN 'dona'
        ELSE 'none'
    END AS TITLE
FROM titanic_train;
    
CREATE OR REPLACE VIEW titanic_test_advanced AS
SELECT 
    --CABIN,
    --NAME,
    PASSENGERID,
    PCLASS,
    SEX,
    CASE 
        WHEN AGE IS NULL THEN 28.0 ELSE AGE
    END AS AGE,
    SIBSP,
    PARCH,
    FARE,
    --CASE 
    --    WHEN FARE < 7.9104 THEN 'TIER1'
    --    WHEN FARE >= 7.9104 AND FARE < 14.4542 THEN 'TIER2'
    --    WHEN FARE >= 14.4542 AND FARE < 31.0 THEN 'TIER3'
    --    ELSE 'TIER4'
    --END AS FARE_TIER,
    TICKET,
    EMBARKED,
    CASE
        WHEN (SIBSP + PARCH) BETWEEN 1 AND 3 THEN 'SMALL'
        WHEN (SIBSP + PARCH) BETWEEN 4 AND 5 THEN 'MEDIUM'
        WHEN (SIBSP + PARCH) > 6 THEN 'LARGE'
    ELSE 'ALONE'
    END AS FAMILY_SIZE,
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss'
        WHEN LOWER(NAME) LIKE '%ms.%' THEN 'ms'
        --WHEN LOWER(NAME) LIKE '%col.%' THEN 'col'
        --WHEN LOWER(NAME) LIKE '%rev.%' THEN 'rev'
        --WHEN LOWER(NAME) LIKE '%dona.%' THEN 'dona'
        ELSE 'none'
    END AS TITLE
FROM titanic_test;

-- Check train and test data sets with advanced features
SELECT * FROM titanic_train_advanced;
SELECT * FROM titanic_test_advanced;

-- Train a model on train data set with advanced no. of features
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION my_titanic_model_advanced(
	INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'titanic_train_advanced'),
	TARGET_COLNAME => 'SURVIVED'
);

-- Confirm that model exists
SHOW snowflake.ml.classification;

-- Generate predictions
SELECT
    titanic_test_advanced.passengerid as PassengerId, 
    CAST(my_titanic_model_advanced!PREDICT(object_construct(*)):class as INTEGER) as Survived
FROM titanic_test_advanced
ORDER BY PASSENGERID ASC

---
--- OPTIONAL STEPS
---

-- Get evaluation metrics
CALL my_titanic_model_advanced!SHOW_EVALUATION_METRICS();
CALL my_titanic_model_advanced!SHOW_GLOBAL_EVALUATION_METRICS();
CALL my_titanic_model_advanced!SHOW_CONFUSION_MATRIX();

-- Get feature importances
CALL my_titanic_model_advanced!SHOW_FEATURE_IMPORTANCE();

CALL my_titanic_model!SHOW_FEATURE_IMPORTANCE();

-- Drop model
DROP SNOWFLAKE.ML.CLASSIFICATION my_titanic_model_advanced;

-- Drop views
DROP VIEW titanic_test_advanced;
DROP VIEW titanic_train_advanced;