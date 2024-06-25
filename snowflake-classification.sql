SELECT * FROM KAGGLE.PUBLIC.TITANIC_TRAIN LIMIT;

SELECT * FROM KAGGLE.PUBLIC.TITANIC_TEST;

-- Train a model on train data 
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION my_titanic_model(
	INPUT_DATA => SYSTEM$REFERENCE('TABLE', 'titanic_train'),
	TARGET_COLNAME => 'SURVIVED'
);

-- Generate predictions
CREATE OR REPLACE TABLE my_predictions AS SELECT
my_titanic_model!PREDICT(object_construct(*)) as prediction 
FROM titanic_test;

SELECT prediction:class as Survived, CURRENT_TIMESTAMP() FROM my_predictions;

SELECT passengerid as PassengerId FROM KAGGLE.PUBLIC.TITANIC_TEST;

DROP TABLE my_predictions;

CREATE OR REPLACE TABLE my_predictions AS SELECT
prediction:class as Survived,
FROM 
(SELECT my_titanic_model!PREDICT(object_construct(*)) as prediction 
FROM titanic_test);

CREATE OR REPLACE TABLE combined_data AS 
SELECT PASSENGERID FROM KAGGLE.PUBLIC.TITANIC_TRAIN
UNION ALL
SELECT Survived FROM my_predictions;

SELECT * FROM combined_data;

-- Get evaluation metrics
CALL my_titanic_model!SHOW_EVALUATION_METRICS();
CALL my_titanic_model!SHOW_GLOBAL_EVALUATION_METRICS();
CALL my_titanic_model!SHOW_CONFUSION_MATRIX();

-- Get feature importances
CALL my_titanic_model!SHOW_FEATURE_IMPORTANCE();