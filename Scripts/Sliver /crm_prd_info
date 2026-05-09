-- this two tables are connected 
SELECT TOP (1000) [prd_id]
      ,[prd_key]
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [Warehouse_Project_Data].[Bronze].[crm_prd_info]

  SELECT TOP (1000) [ID]
      ,[CAT]
      ,[SUBCAT]
      ,[MAINTENANCE]
  FROM [Warehouse_Project_Data].[Bronze].[erp_PX_CAT_G1V2]

-- CHECKING FOR ANY NULLS check 
  SELECT
  prd_id,
  COUNT(*)
  FROM Bronze.crm_prd_info
  GROUP BY prd_id
  HAVING COUNT(*) > 1 OR prd_id IS NULL 
;
-- DATA Standardization & consistency check
SELECT DISTINCT Prd_line 
FROM Bronze.crm_prd_info ;

-- CHECK FOR INVALID DATE ORDERS 
SELECT * FROM Bronze.crm_prd_info
WHERE prd_end_dt <  prd_start_dt ;
  
SELECT 
    prd_key
    ,prd_start_dt
    ,prd_end_dt
    ,ROW_NUMBER() OVER (Partition BY prd_nm order BY prd_start_dt)
    ,CAST(LEAD(prd_start_dt) OVER (Partition BY prd_key order BY prd_start_dt) AS datetime)-1 AS prd_end_dt
FROM Bronze.crm_prd_info
--droping and createing table for stuctual changes done in prd_key
	DROP TABLE Silver.crm_prd_info;
CREATE TABLE Silver.crm_prd_info(
	prd_id INT,
    cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME DEFAULT GETDATE()
);

INSERT INTO  [Warehouse_Project_Data].[Silver].[crm_prd_info]
([prd_id]
      ,cat_id
      ,[prd_key]
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt])
SELECT 
prd_id
,REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id
,REPLACE(SUBSTRING(prd_key, 7, LEN(prd_key)),'-','_') AS prd_key
,prd_nm
,COALESCE(prd_cost,0) AS prd_cost
,CASE UPPER(TRIM(prd_line))
      WHEN 'M' THEN 'Mountain'
      WHEN 'R' THEN 'Road'
      WHEN 'S' THEN 'Other Sales'
      WHEN 'M' THEN 'Touring'
 ELSE 'n/a' 
 END AS prd_line
,prd_start_dt
,CAST(CAST(LEAD(prd_start_dt) OVER (Partition BY prd_key order BY prd_start_dt) AS datetime)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info


