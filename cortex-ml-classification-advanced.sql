-- Check train data set
SELECT * FROM TITANIC_TRAIN;

-- Let's find out the median age (=28.0)
-- I also tested different median ages for males and females, but it was worse.
SELECT MEDIAN(AGE) FROM TITANIC_TRAIN WHERE AGE IS NOT NULL;

-- Let's find out the median age per sex (=27.0 for females, 29.0 for males)
SELECT MEDIAN(AGE), SEX FROM TITANIC_TRAIN WHERE AGE IS NOT NULL GROUP BY SEX;

-- Let's see the distribution (count) of titles
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
        ELSE ''
    END AS TITLE,
    COUNT(*) AS COUNT
FROM TITANIC_TRAIN
GROUP BY TITLE;

-- Let's find the min, max, avg (mean) and median fare
SELECT 
    MAX(FARE) AS MAX_FARE,
    MIN(FARE) AS MIN_FARE,
    AVG(FARE) AS AVG_FARE,
    MEDIAN(FARE) AS MEDIAN_FARE
FROM 
    (SELECT * FROM TITANIC_TEST UNION SELECT * FROM TITANIC_TEST)
WHERE FARE > 0.0;
    
-- Create train data set with custom features
CREATE OR REPLACE VIEW TITANIC_TRAIN_ADVANCED AS
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
    CASE
        WHEN FARE = 0.0 THEN 3.1708
        ELSE FARE
    END AS FARE,
    TICKET,
    CASE 
        WHEN EMBARKED IS NULL THEN ''
        ELSE EMBARKED
    END AS EMBARKED,
    CASE
        WHEN SIBSP = 0 AND PARCH = 0 THEN TRUE ELSE FALSE
    END AS TRAVELS_ALONE,
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss'
        ELSE ''
    END AS TITLE
FROM TITANIC_TRAIN;

-- Create test data set with custom features
CREATE OR REPLACE VIEW TITANIC_TEST_ADVANCED AS
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
    CASE
        WHEN FARE = 0.0 THEN 3.1708
        ELSE FARE
    END AS FARE,
    TICKET,
    CASE 
        WHEN EMBARKED IS NULL THEN ''
        ELSE EMBARKED
    END AS EMBARKED,
    CASE
        WHEN SIBSP = 0 AND PARCH = 0 THEN TRUE ELSE FALSE
    END AS TRAVELS_ALONE,
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss'
        ELSE ''
    END AS TITLE,
FROM TITANIC_TEST;

-- Check train and test data sets with advanced features
SELECT * FROM TITANIC_TRAIN_ADVANCED;
SELECT * FROM TITANIC_TEST_ADVANCED;

-- Train a model on train data set with custom of features
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION MY_TITANIC_MODEL_ADVANCED(
	INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'titanic_train_advanced'),
	TARGET_COLNAME => 'SURVIVED'
);

-- Confirm that model exists
SHOW SNOWFLAKE.ML.CLASSIFICATION;

-- Generate predictions
SELECT
    TITANIC_TEST_ADVANCED.PASSENGERID as PassengerId, 
    CAST(MY_TITANIC_MODEL_ADVANCED!PREDICT(object_construct(*)):class as INTEGER) as Survived,
FROM titanic_test_advanced
ORDER BY PASSENGERID ASC

---
--- OPTIONAL STEPS
---

-- Get evaluation metrics
CALL MY_TITANIC_MODEL_ADVANCED!SHOW_EVALUATION_METRICS();
CALL MY_TITANIC_MODEL_ADVANCED!SHOW_GLOBAL_EVALUATION_METRICS();
CALL MY_TITANIC_MODEL_ADVANCED!SHOW_CONFUSION_MATRIX();

-- Get feature importances
CALL MY_TITANIC_MODEL_ADVANCED!SHOW_FEATURE_IMPORTANCE();

-- Drop model
DROP SNOWFLAKE.ML.CLASSIFICATION MY_TITANIC_MODEL_ADVANCED;

-- Drop views
DROP VIEW TITANIC_TEST_ADVANCED;
DROP VIEW TITANIC_TRAIN_ADVANCED;