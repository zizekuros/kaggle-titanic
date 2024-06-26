-- Check training data set
SELECT * FROM TITANIC_TRAIN;

-- Check test data set
SELECT * FROM TITANIC_TEST;

-- Train a model on traininig data set
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION MY_TITANIC_MODEL(
	INPUT_DATA => SYSTEM$REFERENCE('TABLE', 'TITANIC_TRAIN'),
	TARGET_COLNAME => 'SURVIVED'
);

-- Confirm that model exists
SHOW SNOWFLAKE.ML.CLASSIFICATION;

-- Generate predictions
SELECT
    TITANIC_TEST.PASSENGERID as PassengerId, 
    CAST(MY_TITANIC_MODEL!PREDICT(object_construct(*)):class as INTEGER) as Survived
FROM TITANIC_TEST
ORDER BY PASSENGERID ASC

---
--- OPTIONAL STEPS
---

-- Get evaluation metrics
CALL MY_TITANIC_MODEL!SHOW_EVALUATION_METRICS();
CALL MY_TITANIC_MODEL!SHOW_GLOBAL_EVALUATION_METRICS();
CALL MY_TITANIC_MODEL!SHOW_CONFUSION_MATRIX();

-- Get feature importances
CALL MY_TITANIC_MODEL!SHOW_FEATURE_IMPORTANCE();

-- Drop model
DROP SNOWFLAKE.ML.CLASSIFICATION MY_TITANIC_MODEL;