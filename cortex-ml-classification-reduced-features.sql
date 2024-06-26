-- Train data set
SELECT * FROM KAGGLE.PUBLIC.TITANIC_TRAIN LIMIT 10;

-- Create a Views (titanic_train_reduced, titanic_test_reduced) 
-- These views exclude some features, in particular: NAME, TICKET, CABIN, EMBARKED
CREATE OR REPLACE VIEW titanic_train_reduced AS
SELECT 
    PASSENGERID,
    SURVIVED,
    PCLASS,
    SEX,
    AGE,
    SIBSP,
    PARCH,
    FARE
FROM titanic_train;

CREATE OR REPLACE VIEW titanic_test_reduced AS
SELECT 
    PASSENGERID,
    PCLASS,
    SEX,
    AGE,
    SIBSP,
    PARCH,
    FARE
FROM titanic_test;

-- Check train and test data sets with reduced features
SELECT * FROM titanic_train_reduced;
SELECT * FROM titanic_test_reduced;

-- Train a model on train data set with reduced no. of features
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION my_titanic_model_reduced(
	INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'titanic_train_reduced'),
	TARGET_COLNAME => 'SURVIVED'
);

-- Confirm that model exists
SHOW snowflake.ml.classification;

-- Generate predictions
SELECT
    titanic_test_reduced.passengerid as PassengerId, 
    CAST(my_titanic_model_reduced!PREDICT(object_construct(*)):class as INTEGER) as Survived
FROM titanic_test_reduced
ORDER BY PASSENGERID ASC

---
--- OPTIONAL STEPS:
---

-- Get evaluation metrics
CALL my_titanic_model_reduced!SHOW_EVALUATION_METRICS();
CALL my_titanic_model_reduced!SHOW_GLOBAL_EVALUATION_METRICS();
CALL my_titanic_model_reduced!SHOW_CONFUSION_MATRIX();

-- Get feature importances
CALL my_titanic_model_reduced!SHOW_FEATURE_IMPORTANCE();

-- Drop model
DROP SNOWFLAKE.ML.CLASSIFICATION my_titanic_model_reduced;

-- Drop views
DROP VIEW titanic_test_reduced;
DROP VIEW titanic_train_reduced;