CREATE TABLE "KAGGLE"."PUBLIC"."titanic_test" ( PassengerId NUMBER(38, 0) , Pclass NUMBER(38, 0) , Name VARCHAR , Sex VARCHAR , Age NUMBER(38, 2) , SibSp NUMBER(38, 0) , Parch NUMBER(38, 0) , Ticket VARCHAR , Fare NUMBER(38, 4) , Cabin VARCHAR , Embarked VARCHAR ); 

CREATE TEMP FILE FORMAT "KAGGLE"."PUBLIC"."temp_file_format_2024-06-25T14:14:23.215Z"
	TYPE=CSV
    SKIP_HEADER=1
    FIELD_DELIMITER=','
    TRIM_SPACE=TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY='"'
    REPLACE_INVALID_CHARACTERS=TRUE
    DATE_FORMAT=AUTO
    TIME_FORMAT=AUTO
    TIMESTAMP_FORMAT=AUTO; 

COPY INTO "KAGGLE"."PUBLIC"."titanic_test" 
FROM (SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
	FROM '@"KAGGLE"."PUBLIC"."__snowflake_temp_import_files__"') 
FILES = ('2024-06-25T14:13:42.491Z/test.csv') 
FILE_FORMAT = '"KAGGLE"."PUBLIC"."temp_file_format_2024-06-25T14:14:23.215Z"' 
ON_ERROR=ABORT_STATEMENT 
-- For more details, see: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table