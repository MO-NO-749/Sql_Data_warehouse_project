--CHECK FOR NULLS OR DUPLICATE IN PRIMARY KEY
-- EXPECTATION: NO RESULT 
SELECT
  cst_id,
  COUNT(*)
  FROM Bronze.crm_cust_info
  GROUP BY cst_id 
  HAVING COUNT(*) > 1 OR cst_id IS NULL 
;

  -- IDENTIFIING DUPLICATES
  SELECT * FROM 
  (SELECT * ,
  ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as valid_data 
  FROM Bronze.crm_cust_info
  )t
  WHERE valid_data != 1
;

-- IDENFING INCONSISTENCY AND NULLS IN DATA THIS OPERATION IS WITH EACH COLUME 
SELECT cst_key FROM Bronze.crm_cust_info 
WHERE cst_key != TRIM(cst_key)
;
SELECT DISTINCT cst_key FROM Bronze.crm_cust_info 
;

-- INSERTING CLEANED DATA IN SILVER LAYER 
 INSERT INTO  [Warehouse_Project_Data].[Silver].[crm_cust_info]
      ([cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]
  )  
-- CLEANING, EDITING AND CHANGING DATA BASED ON FINDING FROM 1ST 4 QUERYS   
  SELECT 
  cst_id
  ,cst_key
  ,TRIM(cst_firstname) AS cst_firstname 
  ,TRIM(cst_lastname) AS cst_lastname
  ,CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
        END AS  cst_marital_status
  ,CASE WHEN cst_gndr = 'M' THEN 'Male'
        WHEN cst_gndr = 'F' THEN 'Female'
        ELSE 'n/a' 
        END AS cst_gndr
  ,cst_create_date
  FROM
  (SELECT * ,
  ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as valid_data 
  FROM Bronze.crm_cust_info
  )t
  WHERE valid_data = 1 AND cst_id IS NOT NULL ;
