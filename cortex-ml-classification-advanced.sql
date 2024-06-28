-- Train data set
SELECT * FROM KAGGLE.PUBLIC.TITANIC_TRAIN;

-- Let's find out the median age (=28.0)
-- I also tested different median ages for males and females, but it was worse.
SELECT MEDIAN(AGE) FROM TITANIC_TRAIN WHERE AGE IS NOT NULL;

-- Let's find out the median age per sex (=27.0 for females, 29.0 for males)
SELECT MEDIAN(AGE), SEX FROM TITANIC_TRAIN WHERE AGE IS NOT NULL GROUP BY SEX;

-- Let's see how much % of people survived (342/891 -> 38,38%)
SELECT COUNT(*) AS COUNT, SURVIVED FROM TITANIC_TRAIN GROUP BY SURVIVED;

-- Let's see how much % of dr.'s survived (3/7 -> 42,9%)
-- We are going to add this as one of the titles
SELECT COUNT(SURVIVED) AS COUNT, SURVIVED FROM TITANIC_TRAIN WHERE LOWER(NAME) LIKE '%dr.%' GROUP BY SURVIVED;

-- Let's presume people younger than 15 and older than 60 needs help. First, let's check how many of survived (=50%)
-- I tried to add this feature but doesn't help much (worse score)
SELECT COUNT(SURVIVED) AS COUNT, SURVIVED FROM TITANIC_TRAIN WHERE AGE < 15 OR AGE > 60 GROUP BY SURVIVED;

-- Create a Views (titanic_train_advanced, titanic_test_advanced) 
-- Excluded: CABIN, NAME
-- Added: AGE for NULL
-- Added: TRAVELS_ALONE (1 or 0) 
-- Added: TITLE (Mrs., Miss., Dr., Master.)
CREATE OR REPLACE VIEW titanic_train_advanced AS
SELECT 
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
    TICKET,
    EMBARKED,
    CASE
        WHEN SIBSP = 0 AND PARCH = 0 THEN 1 ELSE 0
    END AS TRAVELS_ALONE,
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss' 
        ELSE ''
    END AS TITLE
FROM titanic_train;
    
CREATE OR REPLACE VIEW titanic_test_advanced AS
SELECT 
    PASSENGERID,
    PCLASS,
    SEX,
    CASE 
        WHEN AGE IS NULL THEN 28.0 ELSE AGE
    END AS AGE,
    SIBSP,
    PARCH,
    FARE,
    TICKET,
    EMBARKED,
    CASE
        WHEN SIBSP = 0 AND PARCH = 0 THEN 1 ELSE 0
    END AS TRAVELS_ALONE,
    CASE
        WHEN LOWER(NAME) LIKE '%dr.%' THEN 'dr'
        WHEN LOWER(NAME) LIKE '%master.%' THEN 'master' 
        WHEN LOWER(NAME) LIKE '%mr.%' THEN 'mr' 
        WHEN LOWER(NAME) LIKE '%mrs.%' THEN 'mrs' 
        WHEN LOWER(NAME) LIKE '%miss.%' THEN 'miss' 
        ELSE ''
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

-- Drop model
DROP SNOWFLAKE.ML.CLASSIFICATION my_titanic_model_advanced;

-- Drop views
DROP VIEW titanic_test_advanced;
DROP VIEW titanic_train_advanced;