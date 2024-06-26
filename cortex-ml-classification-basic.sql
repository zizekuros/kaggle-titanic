-- Check training data set
SELECT * FROM KAGGLE.PUBLIC.TITANIC_TRAIN LIMIT 10;

-- Check test data set
SELECT * FROM KAGGLE.PUBLIC.TITANIC_TEST ORDER BY PASSENGERID ASC LIMIT 10;

-- Train a model on traininig data set
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION my_titanic_model(
	INPUT_DATA => SYSTEM$REFERENCE('TABLE', 'titanic_train'),
	TARGET_COLNAME => 'SURVIVED'
);

-- Confirm that model exists
SHOW snowflake.ml.classification;

-- Generate predictions
SELECT
    titanic_test.passengerid as PassengerId, 
    CAST(my_titanic_model!PREDICT(object_construct(*)):class as INTEGER) as Survived
FROM titanic_test
ORDER BY PASSENGERID ASC

---
--- OPTIONAL STEPS
---

-- Get evaluation metrics
CALL my_titanic_model!SHOW_EVALUATION_METRICS();
CALL my_titanic_model!SHOW_GLOBAL_EVALUATION_METRICS();
CALL my_titanic_model!SHOW_CONFUSION_MATRIX();

-- Get feature importances
CALL my_titanic_model!SHOW_FEATURE_IMPORTANCE();

-- Drop model
DROP SNOWFLAKE.ML.CLASSIFICATION my_titanic_model;